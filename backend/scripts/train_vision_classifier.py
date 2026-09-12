"""Trains the real disease classifier head used by app/services/vision_service.py.

Approach: frozen-backbone + linear probe. EfficientNet-B0 (ImageNet-pretrained) is used
purely as a fixed feature extractor -- no backprop through it, no fine-tuning of its
weights. A small nn.Linear(1280, num_classes) head is trained on cached embeddings,
which is fast because it never touches raw images again after the (only CPU-heavy)
embedding step. This is the standard low-compute transfer-learning technique and is what
makes real training feasible on CPU-only hardware in minutes instead of hours.

Training images are augmented (random crop, flip, rotation, color jitter) before
embedding, and each is embedded --augmentations-per-image times with fresh random
augmentation. This dataset (assets/disease_references/) is PlantVillage-style: plain,
uniform backgrounds and centered, well-lit leaves. A model trained without augmentation
hits ~97% val accuracy on more images from the *same* distribution while badly
overfitting to that background/lighting style -- it then fails to generalize to real
farmer photos (different background, lighting, framing). Augmentation does not fix this
gap (no amount of crop/rotate/color-jitter invents a realistic new background), but it
meaningfully reduces reliance on exact framing/lighting/backdrop, which is the largest
part of the gap this frozen-backbone approach can address without collecting real field
photos or fine-tuning the backbone itself.

Run with: python -m scripts.train_vision_classifier   (from backend/, venv active)
"""

import argparse
import json
import random
import sys
import time
from pathlib import Path

import torch
import torchvision.transforms as T
from PIL import Image
from torch.utils.data import DataLoader, Dataset, TensorDataset
from torchvision.models import EfficientNet_B0_Weights, efficientnet_b0

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

DATA_DIR = Path(__file__).resolve().parent.parent / "assets" / "disease_references"
TRAIN_DIR = DATA_DIR / "Train"
VAL_DIR = DATA_DIR / "Val"
ARTIFACT_DIR = Path(__file__).resolve().parent.parent / "app" / "ml_artifacts"

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


class ImageListDataset(Dataset):
    """Loads (path, label_idx) pairs. `transforms` may be the exact inference-time
    preprocessing (deterministic, used for Val) or a randomized augmentation pipeline
    (used for Train) -- each __getitem__ call re-applies the transform, so repeating the
    same path multiple times in `items` naturally yields differently-augmented copies.
    """

    def __init__(self, items: list[tuple[Path, int]], transforms):
        self.items = items
        self.transforms = transforms

    def __len__(self):
        return len(self.items)

    def __getitem__(self, idx):
        path, label = self.items[idx]
        with Image.open(path) as img:
            tensor = self.transforms(img.convert("RGB"))
        return tensor, label


def build_augment_transform(base_transforms) -> T.Compose:
    """Builds a randomized training-time pipeline matching base_transforms' final
    resolution/normalization (so embeddings stay in the distribution the backbone
    expects), but replacing its fixed resize+center-crop with random crop/flip/rotation/
    color-jitter -- so the linear head sees varied framing and lighting per image
    instead of memorizing one fixed view of each training photo.
    """
    crop_size = base_transforms.crop_size
    crop_size = crop_size[0] if isinstance(crop_size, (list, tuple)) else crop_size
    return T.Compose([
        T.RandomResizedCrop(crop_size, scale=(0.6, 1.0), ratio=(0.8, 1.25)),
        T.RandomHorizontalFlip(),
        T.RandomRotation(25),
        T.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.05),
        T.ToTensor(),
        T.Normalize(mean=base_transforms.mean, std=base_transforms.std),
    ])


def list_classes() -> list[str]:
    classes = sorted(p.name for p in TRAIN_DIR.iterdir() if p.is_dir())
    val_classes = sorted(p.name for p in VAL_DIR.iterdir() if p.is_dir())
    if classes != val_classes:
        raise RuntimeError(f"Train/Val class mismatch: {set(classes) ^ set(val_classes)}")
    return classes


def sample_items(split_dir: Path, classes: list[str], per_class: int, seed: int) -> list[tuple[Path, int]]:
    rng = random.Random(seed)
    items = []
    for label_idx, class_name in enumerate(classes):
        files = [p for p in (split_dir / class_name).iterdir() if p.suffix.lower() in IMAGE_EXTENSIONS]
        chosen = rng.sample(files, min(per_class, len(files)))
        items.extend((path, label_idx) for path in chosen)
    rng.shuffle(items)
    return items


def embed_dataset(items: list[tuple[Path, int]], transforms, backbone, batch_size: int, workers: int):
    loader = DataLoader(
        ImageListDataset(items, transforms),
        batch_size=batch_size,
        shuffle=False,
        num_workers=workers,
    )
    embeddings, labels = [], []
    seen = 0
    with torch.no_grad():
        for batch_tensors, batch_labels in loader:
            batch_embeddings = backbone(batch_tensors)
            batch_embeddings = batch_embeddings / batch_embeddings.norm(dim=1, keepdim=True)
            embeddings.append(batch_embeddings)
            labels.append(batch_labels)
            seen += len(batch_labels)
            print(f"  embedded {seen}/{len(items)}", flush=True)
    return torch.cat(embeddings), torch.cat(labels)


def train_head(train_embeddings, train_labels, val_embeddings, val_labels, num_classes: int, epochs: int, lr: float, batch_size: int):
    head = torch.nn.Linear(train_embeddings.shape[1], num_classes)
    # weight_decay adds L2 regularization -- without it the previous augmentation-free
    # run hit train_acc=1.000, a sign the head was free to fit the training embeddings
    # exactly rather than a generalizable boundary.
    optimizer = torch.optim.Adam(head.parameters(), lr=lr, weight_decay=1e-4)
    loss_fn = torch.nn.CrossEntropyLoss()

    loader = DataLoader(TensorDataset(train_embeddings, train_labels), batch_size=batch_size, shuffle=True)

    for epoch in range(epochs):
        head.train()
        total_loss = 0.0
        for batch_embeddings, batch_labels in loader:
            optimizer.zero_grad()
            logits = head(batch_embeddings)
            loss = loss_fn(logits, batch_labels)
            loss.backward()
            optimizer.step()
            total_loss += loss.item() * len(batch_labels)

        if (epoch + 1) % 10 == 0 or epoch == epochs - 1:
            head.eval()
            with torch.no_grad():
                train_acc = (head(train_embeddings).argmax(dim=1) == train_labels).float().mean().item()
                val_acc = (head(val_embeddings).argmax(dim=1) == val_labels).float().mean().item()
            print(f"epoch {epoch + 1}/{epochs}  loss={total_loss / len(train_labels):.4f}  "
                  f"train_acc={train_acc:.3f}  val_acc={val_acc:.3f}", flush=True)

    return head


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--per-class-train", type=int, default=150)
    parser.add_argument("--per-class-val", type=int, default=30)
    parser.add_argument("--augmentations-per-image", type=int, default=4)
    parser.add_argument("--epochs", type=int, default=80)
    parser.add_argument("--lr", type=float, default=0.01)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    torch.manual_seed(args.seed)
    torch.set_num_threads(4)

    classes = list_classes()
    print(f"{len(classes)} classes: {classes}", flush=True)

    weights = EfficientNet_B0_Weights.IMAGENET1K_V1
    backbone = efficientnet_b0(weights=weights)
    backbone.classifier = torch.nn.Identity()
    backbone.eval()
    eval_transforms = weights.transforms()
    augment_transforms = build_augment_transform(eval_transforms)

    train_items = sample_items(TRAIN_DIR, classes, args.per_class_train, args.seed)
    augmented_train_items = train_items * args.augmentations_per_image
    val_items = sample_items(VAL_DIR, classes, args.per_class_val, args.seed)
    print(f"sampled {len(train_items)} train images -> {len(augmented_train_items)} augmented "
          f"({args.augmentations_per_image}x) / {len(val_items)} val images", flush=True)

    start = time.time()
    print("embedding augmented train set...", flush=True)
    train_embeddings, train_labels = embed_dataset(augmented_train_items, augment_transforms, backbone, args.batch_size, args.workers)
    print("embedding val set...", flush=True)
    val_embeddings, val_labels = embed_dataset(val_items, eval_transforms, backbone, args.batch_size, args.workers)
    print(f"embedding took {time.time() - start:.1f}s", flush=True)

    head = train_head(train_embeddings, train_labels, val_embeddings, val_labels, len(classes), args.epochs, args.lr, args.batch_size)

    ARTIFACT_DIR.mkdir(exist_ok=True)
    torch.save(head.state_dict(), ARTIFACT_DIR / "vision_head.pt")
    (ARTIFACT_DIR / "labels.json").write_text(json.dumps(classes, ensure_ascii=False, indent=2))
    print(f"saved artifacts to {ARTIFACT_DIR}", flush=True)


if __name__ == "__main__":
    main()

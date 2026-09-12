"""Real (not mocked) crop-disease vision classifier.

Approach: frozen-backbone + linear probe. EfficientNet-B0 pretrained on ImageNet is used
as a fixed feature extractor (its own classifier head is stripped to expose the 1280-dim
pooled feature). A small nn.Linear(1280, num_classes) head, trained on top of those
frozen embeddings by scripts/train_vision_classifier.py against the labeled dataset in
assets/disease_references/{Train,Val,Test}, does the actual disease classification.
Retrain by running that script; it overwrites app/ml_artifacts/vision_head.pt and
labels.json, which this module loads lazily at first use.
"""

import asyncio
import io
import json
from pathlib import Path

import torch
from PIL import Image, ImageOps
from torchvision.models import EfficientNet_B0_Weights, efficientnet_b0

ARTIFACT_DIR = Path(__file__).resolve().parent.parent / "ml_artifacts"

_backbone = None
_transforms = None
_head = None
_labels: list[str] | None = None
_lock = asyncio.Lock()


def _load_backbone():
    global _backbone, _transforms
    if _backbone is None:
        weights = EfficientNet_B0_Weights.IMAGENET1K_V1
        model = efficientnet_b0(weights=weights)
        model.classifier = torch.nn.Identity()  # expose the 1280-dim pooled feature, not the 1000-way ImageNet head
        model.eval()
        _backbone = model
        _transforms = weights.transforms()
    return _backbone, _transforms


def _load_head():
    global _head, _labels
    if _head is None:
        _labels = json.loads((ARTIFACT_DIR / "labels.json").read_text())
        head = torch.nn.Linear(1280, len(_labels))
        head.load_state_dict(torch.load(ARTIFACT_DIR / "vision_head.pt", map_location="cpu"))
        head.eval()
        _head = head
    return _head, _labels


def _embed(image: Image.Image) -> torch.Tensor:
    backbone, transforms = _load_backbone()
    with torch.no_grad():
        tensor = transforms(image).unsqueeze(0)
        embedding = backbone(tensor).squeeze(0)
        return embedding / embedding.norm()


def _classify_sync(image_bytes: bytes) -> list[dict]:
    head, labels = _load_head()
    with Image.open(io.BytesIO(image_bytes)) as img:
        # Phone/webcam JPEGs commonly carry an EXIF orientation tag that browsers apply
        # for display but PIL does not apply automatically — without this, a photo that
        # looks upright on screen can be fed to the model sideways/upside-down, tanking
        # confidence for real-device photos while lab-condition dataset images (no
        # meaningful EXIF rotation) are unaffected.
        img = ImageOps.exif_transpose(img)
        embedding = _embed(img.convert("RGB"))

    with torch.no_grad():
        probs = torch.softmax(head(embedding.unsqueeze(0)).squeeze(0), dim=0).tolist()

    ranked = sorted(zip(labels, probs), key=lambda pair: pair[1], reverse=True)
    return [{"disease_name_en": name, "confidence": confidence} for name, confidence in ranked]


async def classify_image(image_bytes: bytes) -> list[dict]:
    """Returns disease candidates ranked by confidence, e.g.
    [{"disease_name_en": "Tomato - Late Blight", "confidence": 0.81}, ...].
    Runs the (CPU-bound) model in a worker thread so it doesn't block the
    event loop; a lock serializes calls since torchvision models aren't
    guaranteed thread-safe for concurrent forward passes on shared weights.
    """
    async with _lock:
        return await asyncio.to_thread(_classify_sync, image_bytes)

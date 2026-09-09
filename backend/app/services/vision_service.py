"""Real (not mocked) crop-disease vision classifier.

Approach: EfficientNet-B0 pretrained on ImageNet is used as a frozen feature
extractor (no disease-labeled training set exists for this hackathon's pilot
taxonomy, so there is nothing to fine-tune against). A photo is classified by
cosine similarity between its embedding and one reference-image embedding per
seeded disease (assets/disease_references/). This is a legitimate few-shot /
prototype-matching technique, but it is only as good as its one reference
photo per class — replace with a properly trained, multi-image classifier
before this leaves pilot/demo status. See IMPLEMENTATION_PLAN.md section 4.
"""

import asyncio
import io
from pathlib import Path

import torch
from PIL import Image
from torchvision.models import EfficientNet_B0_Weights, efficientnet_b0

REFERENCE_DIR = Path(__file__).resolve().parent.parent.parent / "assets" / "disease_references"

# disease.name_en -> reference image file. Placeholder photos for diseases
# without a species-exact public-domain source available at seed time
# (bacterial leaf blight, jute stem rot) are noted in scripts/seed_demo.py's
# sibling doc — swap these for real pilot-crop photos before field use.
REFERENCE_FILES = {
    "Rice Blast": "rice_blast.jpg",
    "Bacterial Leaf Blight": "rice_leaf_blight.jpg",
    "Jute Stem Rot": "jute_stem_rot.jpg",
}

_TEMPERATURE = 0.05  # softmax temperature; tuned so a clear match reads as high confidence

_model = None
_transforms = None
_reference_embeddings: dict[str, torch.Tensor] | None = None
_lock = asyncio.Lock()


def _load_model():
    global _model, _transforms
    if _model is None:
        weights = EfficientNet_B0_Weights.IMAGENET1K_V1
        model = efficientnet_b0(weights=weights)
        model.classifier = torch.nn.Identity()  # expose the 1280-dim pooled feature, not the 1000-way ImageNet head
        model.eval()
        _model = model
        _transforms = weights.transforms()
    return _model, _transforms


def _embed(image: Image.Image) -> torch.Tensor:
    model, transforms = _load_model()
    with torch.no_grad():
        tensor = transforms(image).unsqueeze(0)
        embedding = model(tensor).squeeze(0)
        return embedding / embedding.norm()


def _load_reference_embeddings() -> dict[str, torch.Tensor]:
    global _reference_embeddings
    if _reference_embeddings is None:
        embeddings = {}
        for disease_name, filename in REFERENCE_FILES.items():
            path = REFERENCE_DIR / filename
            with Image.open(path) as img:
                embeddings[disease_name] = _embed(img.convert("RGB"))
        _reference_embeddings = embeddings
    return _reference_embeddings


def _classify_sync(image_bytes: bytes) -> list[dict]:
    references = _load_reference_embeddings()
    with Image.open(io.BytesIO(image_bytes)) as img:
        query_embedding = _embed(img.convert("RGB"))

    similarities = {
        name: torch.dot(query_embedding, ref_embedding).item()
        for name, ref_embedding in references.items()
    }
    logits = torch.tensor(list(similarities.values())) / _TEMPERATURE
    probs = torch.softmax(logits, dim=0).tolist()

    ranked = sorted(zip(similarities.keys(), probs), key=lambda pair: pair[1], reverse=True)
    return [{"disease_name_en": name, "confidence": confidence} for name, confidence in ranked]


async def classify_image(image_bytes: bytes) -> list[dict]:
    """Returns disease candidates ranked by confidence, e.g.
    [{"disease_name_en": "Rice Blast", "confidence": 0.81}, ...].
    Runs the (CPU-bound) model in a worker thread so it doesn't block the
    event loop; a lock serializes calls since torchvision models aren't
    guaranteed thread-safe for concurrent forward passes on shared weights.
    """
    async with _lock:
        return await asyncio.to_thread(_classify_sync, image_bytes)

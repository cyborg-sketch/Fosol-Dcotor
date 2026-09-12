"""One-off evaluation: runs the full Test/ split through the exact same crop-filtered,
renormalized confidence pipeline app/api/routes/diagnosis.py uses, to measure real-world
accuracy and calibration at different CONFIDENCE_AUTO_THRESHOLD values -- not just raw
top-1 accuracy, which the diagnosis route never actually uses directly.

Run with: python -m scripts.evaluate_vision_classifier   (from backend/, venv active)
"""

import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services import vision_service

DATA_DIR = Path(__file__).resolve().parent.parent / "assets" / "disease_references"
TEST_DIR = DATA_DIR / "Test"
ARTIFACT_DIR = Path(__file__).resolve().parent.parent / "app" / "ml_artifacts"
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def crop_of(class_name: str) -> str:
    return class_name.split(" - ")[0]


def main():
    import json
    trained_classes = set(json.loads((ARTIFACT_DIR / "labels.json").read_text()))
    all_test_classes = sorted(p.name for p in TEST_DIR.iterdir() if p.is_dir())
    # Test/ has 3 extra Rice classes with no Train/Val counterpart (not in the trained
    # model) -- leftover from the dataset's original rice/jute-era source, unrelated to
    # this evaluation.
    skipped = [c for c in all_test_classes if c not in trained_classes]
    if skipped:
        print(f"Skipping {len(skipped)} Test/ classes with no trained model class: {skipped}\n", flush=True)
    classes = [c for c in all_test_classes if c in trained_classes]
    by_crop = defaultdict(list)
    for class_name in classes:
        by_crop[crop_of(class_name)].append(class_name)

    results = []  # (true_class, top_class, renormalized_confidence)
    total = 0
    for class_name in classes:
        files = [p for p in (TEST_DIR / class_name).iterdir() if p.suffix.lower() in IMAGE_EXTENSIONS]
        for path in files:
            ranking = vision_service._classify_sync(path.read_bytes())  # noqa: SLF001 -- eval script, sync is fine
            crop_diseases = set(by_crop[crop_of(class_name)])
            filtered = [(r["disease_name_en"], r["confidence"]) for r in ranking if r["disease_name_en"] in crop_diseases]
            total_conf = sum(c for _, c in filtered)
            renormalized = sorted(((name, c / total_conf) for name, c in filtered), key=lambda p: p[1], reverse=True)
            top_class, top_conf = renormalized[0]
            results.append((class_name, top_class, top_conf))
            total += 1
            if total % 100 == 0:
                print(f"  evaluated {total}", flush=True)

    print(f"\nEvaluated {total} Test images across {len(classes)} classes.\n")
    for threshold in [0.4, 0.5, 0.6, 0.75, 0.9]:
        auto = [(t, p, c) for t, p, c in results if c >= threshold]
        review = [(t, p, c) for t, p, c in results if c < threshold]
        auto_correct = sum(1 for t, p, c in auto if t == p)
        review_correct = sum(1 for t, p, c in review if t == p)
        overall_correct = sum(1 for t, p, c in results if t == p)
        print(
            f"threshold={threshold:.2f}  "
            f"AUTO_RESOLVED: {len(auto)}/{total} ({len(auto)/total:.1%}), accuracy among those: "
            f"{auto_correct/len(auto):.1%}" if auto else f"threshold={threshold:.2f}  AUTO_RESOLVED: 0",
        )
        if review:
            print(
                f"             NEEDS_REVIEW: {len(review)}/{total} ({len(review)/total:.1%}), "
                f"accuracy among those (i.e. top guess even though escalated): {review_correct/len(review):.1%}"
            )
    print(f"\nOverall top-1 accuracy (ignoring threshold): {overall_correct/total:.1%}")


if __name__ == "__main__":
    main()

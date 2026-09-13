"""Standalone moondream2 inference worker.

Runs under backend/.venv-moondream (transformers==4.44.2), a separate
virtualenv from the main backend/.venv (transformers v5, used by
CLIP/mpnet). moondream2's vendored 2024-era model code (custom
PhiForCausalLM/generate() internals) is incompatible with transformers v5 -
patching the version skew turned out to require reimplementing the
generation loop, so this runs isolated instead of forcing the whole backend
onto an older transformers.

Invoked as a subprocess by vision_service.py: reads a JSON request
({"image_path": ..., "question": ...}) from argv[1] (a path to a JSON file,
to avoid shell-escaping image paths/questions), prints a JSON response
({"answer": ...} or {"error": ...}) to stdout.

Loads the model fresh each invocation (~1-2s for weight loading off local
disk, no re-download) rather than staying resident as a daemon - simpler,
and fine for a hackathon pilot's request volume; revisit if latency becomes
a problem under real load.
"""

import json
import sys


def main():
    request_path = sys.argv[1]
    with open(request_path, "r", encoding="utf-8") as f:
        request = json.load(f)

    import torch
    from PIL import Image
    from transformers import AutoModelForCausalLM, AutoTokenizer

    model_id = "vikhyatk/moondream2"
    revision = "2024-08-26"

    model = AutoModelForCausalLM.from_pretrained(
        model_id, revision=revision, trust_remote_code=True, torch_dtype=torch.float32
    )
    tokenizer = AutoTokenizer.from_pretrained(model_id, revision=revision)

    image = Image.open(request["image_path"]).convert("RGB")
    enc_image = model.encode_image(image)
    answer = model.answer_question(enc_image, request["question"], tokenizer)

    print(json.dumps({"answer": answer}))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # noqa: BLE001 - report any failure back to the caller as JSON
        print(json.dumps({"error": f"{type(exc).__name__}: {exc}"}))
        sys.exit(1)

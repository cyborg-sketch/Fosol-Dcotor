import base64
import json
import urllib.request

QUESTION = (
    "Look at this plant leaf or stem photo. Which one of these best describes what you see: "
    "'Rice Blast' (brown, eye-shaped or diamond-shaped lesions with gray or white centers on a rice leaf), "
    "'Bacterial Leaf Blight' (yellowing that starts at the leaf tip or edge and spreads inward, on a rice leaf), "
    "'Jute Stem Rot' (blackish rot and softening at the base of a jute plant's stem), "
    "or 'Healthy' (no visible disease)? Answer with just one of those four names."
)

images = {
    "Rice Blast (correct answer)": "/tmp/test_rice_blast.jpg",
    "Bacterial Leaf Blight (correct answer)": "/tmp/test_leaf_blight.jpg",
    "Jute Stem Rot (correct answer)": "/tmp/test_stem_rot.jpg",
}

for label, path in images.items():
    with open(path, "rb") as f:
        img_b64 = base64.b64encode(f.read()).decode()

    payload = json.dumps({"model": "qwen2.5vl:3b", "prompt": QUESTION, "images": [img_b64], "stream": False}).encode()
    req = urllib.request.Request(
        "http://localhost:11434/api/generate", data=payload, headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=180) as resp:
        response = json.loads(resp.read())
    print(f"{label}: {response['response'].strip()}")

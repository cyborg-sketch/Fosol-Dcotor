import asyncio
import sys

sys.path.insert(0, ".")
from app.services import vision_service


async def main():
    with open("/tmp/test_rice_blast.jpg", "rb") as f:
        image_bytes = f.read()

    candidates = ["Rice Blast", "Bacterial Leaf Blight", "Jute Stem Rot"]
    ranked = await vision_service.classify_image(image_bytes, candidates)
    for r in ranked:
        print(r)


asyncio.run(main())

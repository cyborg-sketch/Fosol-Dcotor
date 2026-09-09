import uuid
from pathlib import Path

from fastapi import APIRouter, HTTPException, UploadFile

router = APIRouter(prefix="/images", tags=["images"])

UPLOAD_DIR = Path(__file__).resolve().parent.parent.parent.parent / "uploads"
UPLOAD_DIR.mkdir(exist_ok=True)

ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}


@router.post("/upload")
async def upload_image(file: UploadFile):
    """Stores the farmer's photo so /diagnoses can run vision inference on
    it server-side. The mobile app only ever has a local device path — this
    is the one place actual image bytes cross the wire.
    """
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(status_code=415, detail=f"Unsupported content type: {file.content_type}")

    extension = {"image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"}[file.content_type]
    filename = f"{uuid.uuid4()}.{extension}"
    destination = UPLOAD_DIR / filename

    contents = await file.read()
    destination.write_bytes(contents)

    return {"image_ref": filename}

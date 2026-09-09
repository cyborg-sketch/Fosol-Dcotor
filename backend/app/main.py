from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import dashboard, demo, diagnosis, field_worker, images

app = FastAPI(title="Fasol Doctor API", version="0.1.0")

# Dev-only: the Flutter web build runs on a different origin (localhost:5173)
# than the API (localhost:8000). Native Android builds don't need this.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(diagnosis.router)
app.include_router(field_worker.router)
app.include_router(dashboard.router)
app.include_router(demo.router)
app.include_router(images.router)


@app.get("/health")
def health():
    return {"status": "ok"}

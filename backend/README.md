# Fasol Doctor — Backend (FastAPI)

## Setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # then fill in DATABASE_URL + API keys
```

## Database

```bash
createdb fasol_doctor
alembic revision --autogenerate -m "init schema"
alembic upgrade head
```

## Run

```bash
uvicorn app.main:app --reload
```

API docs: http://localhost:8000/docs

## Layout

```
app/
  main.py              FastAPI app + router registration
  core/config.py        env-driven settings (DATABASE_URL, thresholds, API keys)
  db/                    engine/session + declarative base (imports all models)
  models/                SQLAlchemy models: farmer, crop, disease, symptom,
                         treatment, diagnosis (+candidates/treatments), field_worker,
                         expert_review, region
  schemas/               Pydantic request/response contracts
  services/
    vision_service.py         online vision model adapter (stub)
    stt_service.py            Bangla STT adapter (stub)
    symptom_extractor.py      LLM symptom extraction, strict JSON only (stub)
    confidence_engine.py      deterministic auto/escalate threshold logic
    treatment_engine.py       deterministic treatment ranking (never LLM-ranked)
  api/routes/
    diagnosis.py           POST/GET /diagnoses
    field_worker.py        GET /field-worker/queue, POST .../resolve
    dashboard.py           GET /dashboard/trends
```

The three `services/*_service.py` / `symptom_extractor.py` adapters are stubs that raise
`NotImplementedError` — wire in the chosen providers there during the 12–24h milestone.
The confidence and treatment engines are already deterministic and don't need a provider
choice to be functional; they're the pieces the BRD requires to never be LLM-driven.

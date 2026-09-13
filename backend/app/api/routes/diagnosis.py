import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.routes.images import UPLOAD_DIR
from app.db.session import get_db
from app.models.crop import Crop
from app.models.diagnosis import Diagnosis, DiagnosisCandidate, DiagnosisTreatment
from app.models.disease import Disease
from app.schemas.diagnosis import (
    DiagnosisCandidateOut,
    DiagnosisCreateRequest,
    DiagnosisResult,
    TreatmentOut,
)
from app.services import symptom_extractor, vision_service
from app.services.confidence_engine import resolve_status
from app.services.treatment_engine import rank_treatments

router = APIRouter(prefix="/diagnoses", tags=["diagnoses"])


async def _rank_candidates(payload: DiagnosisCreateRequest, candidates: list[Disease]) -> list[tuple[Disease, float]]:
    """Runs the real vision or symptom-matching model and returns
    (Disease, confidence) pairs restricted to this crop's seeded diseases,
    ranked highest-confidence first.
    """
    if payload.image_ref:
        image_path = UPLOAD_DIR / payload.image_ref
        if not image_path.exists():
            raise HTTPException(status_code=404, detail=f"Uploaded image not found: {payload.image_ref}")
        vision_ranking = await vision_service.classify_image(image_path.read_bytes())

        by_name_en = {d.name_en: d for d in candidates}
        ranked = [
            (by_name_en[r["disease_name_en"]], r["confidence"])
            for r in vision_ranking
            if r["disease_name_en"] in by_name_en
        ]
        if not ranked:
            # No seeded disease matches any of the model's classes for this crop —
            # fall back to an even, low-confidence spread rather than pretending certainty.
            return [(d, 1 / len(candidates)) for d in candidates]

        # The vision model's softmax runs over all classes it was trained on, not just
        # this crop's — renormalize the filtered subset back to sum to 1 so the
        # confidence threshold in confidence_engine still means "how sure among this
        # crop's diseases," not "how sure among every disease in the whole dataset."
        total = sum(confidence for _, confidence in ranked)
        return [(disease, confidence / total) for disease, confidence in ranked]

    if payload.symptoms:
        transcript = " ".join(payload.symptoms.symptoms)
        match_candidates = [{"disease_id": d.id, "description_bn": d.description_bn} for d in candidates]
        symptom_ranking = await symptom_extractor.match_symptoms(transcript, match_candidates)

        by_id = {d.id: d for d in candidates}
        return [(by_id[r["disease_id"]], r["confidence"]) for r in symptom_ranking]

    raise HTTPException(status_code=422, detail="Provide either image_ref or symptoms")


@router.post("", response_model=DiagnosisResult)
async def create_diagnosis(payload: DiagnosisCreateRequest, db: Session = Depends(get_db)):
    """Orchestrates the real diagnosis pipeline: vision (EfficientNet-B0
    prototype matching) for a photo, BanglaBERT symptom-similarity matching
    for voice/text — then applies the deterministic confidence threshold and
    treatment ranking rules exactly as the plan requires (models never
    invent treatment content or their own confidence normalization).
    """
    if payload.crop_id:
        candidates = db.query(Disease).filter(Disease.crop_id == payload.crop_id).all()
    else:
        candidates = db.query(Disease).all()

    if not candidates:
        raise HTTPException(status_code=422, detail="No seeded diseases yet")

    ranked = await _rank_candidates(payload, candidates)
    top_disease, top_confidence = ranked[0]
    status = resolve_status(top_confidence)

    crop_id = payload.crop_id or top_disease.crop_id
    diagnosis = Diagnosis(
        farmer_id=payload.farmer_id,
        crop_id=crop_id,
        image_ref=payload.image_ref,
        symptoms_json=payload.symptoms.model_dump() if payload.symptoms else None,
        confidence=top_confidence,
        source=payload.source,
        model_version="efficientnet-b0-linear-head-v1" if payload.image_ref else "banglabert-similarity-v1",
        status=status,
    )
    db.add(diagnosis)
    db.flush()

    candidate_rows = [
        DiagnosisCandidate(diagnosis_id=diagnosis.id, disease_id=disease.id, confidence=confidence, rank=i + 1)
        for i, (disease, confidence) in enumerate(ranked[:3])
    ]
    db.add_all(candidate_rows)

    treatments = rank_treatments(db, top_disease.id)
    treatment_rows = [
        DiagnosisTreatment(diagnosis_id=diagnosis.id, treatment_id=t.id, rank=i + 1)
        for i, t in enumerate(treatments)
    ]
    db.add_all(treatment_rows)
    db.commit()
    db.refresh(diagnosis)

    crop = db.get(Crop, diagnosis.crop_id)
    return DiagnosisResult(
        id=diagnosis.id,
        status=diagnosis.status,
        confidence=diagnosis.confidence,
        crop_id=diagnosis.crop_id,
        crop_name_bn=crop.name_bn if crop else None,
        image_ref=diagnosis.image_ref,
        candidates=[
            DiagnosisCandidateOut(disease_id=disease.id, disease_name_bn=disease.name_bn, confidence=confidence)
            for disease, confidence in ranked[:3]
        ],
        treatments=[
            TreatmentOut(id=t.id, action_bn=t.action_bn, category=t.category, safety_notes_bn=t.safety_notes_bn)
            for t in treatments
        ],
        created_at=diagnosis.created_at,
    )


@router.get("/{diagnosis_id}", response_model=DiagnosisResult)
def get_diagnosis(diagnosis_id: uuid.UUID, db: Session = Depends(get_db)):
    diagnosis = db.get(Diagnosis, diagnosis_id)
    if not diagnosis:
        raise HTTPException(status_code=404, detail="Diagnosis not found")

    candidates = db.query(DiagnosisCandidate).filter_by(diagnosis_id=diagnosis.id).order_by(DiagnosisCandidate.rank).all()
    diagnosis_treatments = db.query(DiagnosisTreatment).filter_by(diagnosis_id=diagnosis.id).order_by(DiagnosisTreatment.rank).all()

    disease_map = {d.id: d for d in db.query(Disease).filter(Disease.id.in_([c.disease_id for c in candidates])).all()}
    from app.models.treatment import Treatment as TreatmentModel
    treatment_map = {t.id: t for t in db.query(TreatmentModel).filter(TreatmentModel.id.in_([dt.treatment_id for dt in diagnosis_treatments])).all()}

    crop = db.get(Crop, diagnosis.crop_id)
    return DiagnosisResult(
        id=diagnosis.id,
        status=diagnosis.status,
        confidence=diagnosis.confidence,
        crop_id=diagnosis.crop_id,
        crop_name_bn=crop.name_bn if crop else None,
        image_ref=diagnosis.image_ref,
        candidates=[
            DiagnosisCandidateOut(
                disease_id=c.disease_id,
                disease_name_bn=disease_map[c.disease_id].name_bn,
                confidence=c.confidence,
            )
            for c in candidates
        ],
        treatments=[
            TreatmentOut(
                id=treatment_map[dt.treatment_id].id,
                action_bn=treatment_map[dt.treatment_id].action_bn,
                category=treatment_map[dt.treatment_id].category,
                safety_notes_bn=treatment_map[dt.treatment_id].safety_notes_bn,
            )
            for dt in diagnosis_treatments
        ],
        created_at=diagnosis.created_at,
    )

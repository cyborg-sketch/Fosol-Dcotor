"""Seeds the 3-5 pilot crop/disease taxonomy called for in the 0-4h milestone
(IMPLEMENTATION_PLAN.md section 7) plus a couple of demo diagnoses, so the
field-worker queue and BRAC trend dashboard have something real to show.

Run with: python -m scripts.seed_demo   (from backend/, venv active)
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.db.session import SessionLocal
from app.models.crop import Crop
from app.models.diagnosis import Diagnosis, DiagnosisCandidate, DiagnosisTreatment
from app.models.disease import Disease
from app.models.farmer import Farmer
from app.models.field_worker import FieldWorker
from app.models.region import Region
from app.models.treatment import Treatment


def run():
    db = SessionLocal()
    try:
        if db.query(Crop).count() > 0:
            print("Already seeded — skipping. Delete rows manually to reseed.")
            return

        rangpur = Region(district="রংপুর", upazila="মিঠাপুকুর")
        dinajpur = Region(district="দিনাজপুর", upazila="বিরল")
        db.add_all([rangpur, dinajpur])
        db.flush()

        rice = Crop(name_en="Rice", name_bn="ধান")
        jute = Crop(name_en="Jute", name_bn="পাট")
        eggplant = Crop(name_en="Eggplant", name_bn="বেগুন")
        db.add_all([rice, jute, eggplant])
        db.flush()

        rice_blast = Disease(
            crop_id=rice.id,
            name_en="Rice Blast",
            name_bn="ধানের ব্লাস্ট রোগ",
            description_bn="ছত্রাকের আক্রমণে পাতায় চোখের মতো দাগ ও শীষ শুকিয়ে যাওয়া।",
        )
        rice_leaf_blight = Disease(
            crop_id=rice.id,
            name_en="Bacterial Leaf Blight",
            name_bn="আমনের পাতা পোড়া রোগ",
            description_bn="পাতার কিনারা থেকে হলুদ হয়ে শুকিয়ে যাওয়া।",
        )
        jute_stem_rot = Disease(
            crop_id=jute.id,
            name_en="Jute Stem Rot",
            name_bn="পাটের কাণ্ড পচা রোগ",
            description_bn="কাণ্ডের গোড়ায় কালচে দাগ ও নরম হয়ে যাওয়া।",
        )
        db.add_all([rice_blast, rice_leaf_blight, jute_stem_rot])
        db.flush()

        rice_blast_organic = Treatment(
            disease_id=rice_blast.id,
            action_bn="নিমতেল স্প্রে, সপ্তাহে ২ বার আক্রান্ত জমিতে প্রয়োগ করুন।",
            category="organic",
            cost_level=1,
            effectiveness_rating=4,
            safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।",
            approved=True,
        )
        rice_blast_chemical = Treatment(
            disease_id=rice_blast.id,
            action_bn="ট্রাইসাইক্লাজল — প্যাকেটের নির্দেশনা অনুযায়ী মাত্রায় স্প্রে করুন।",
            category="chemical",
            cost_level=2,
            effectiveness_rating=5,
            safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।",
            approved=True,
        )
        db.add_all([rice_blast_organic, rice_blast_chemical])
        db.flush()

        farmer1 = Farmer(phone="+8801710000001", name="রহমত আলী", region_id=rangpur.id)
        farmer2 = Farmer(phone="+8801710000002", name="সালমা বেগম", region_id=dinajpur.id)
        db.add_all([farmer1, farmer2])
        db.flush()

        field_worker = FieldWorker(name="কৃষি কর্মকর্তা - রংপুর", phone="+8801910000001", region_id=rangpur.id)
        db.add(field_worker)
        db.flush()

        # High-confidence, auto-resolved diagnosis
        diag1 = Diagnosis(
            farmer_id=farmer1.id,
            crop_id=rice.id,
            region_id=rangpur.id,
            confidence=0.94,
            source="online",
            model_version="vision-v0-demo",
            status="AUTO_RESOLVED",
        )
        db.add(diag1)
        db.flush()
        db.add_all([
            DiagnosisCandidate(diagnosis_id=diag1.id, disease_id=rice_blast.id, confidence=0.94, rank=1),
            DiagnosisTreatment(diagnosis_id=diag1.id, treatment_id=rice_blast_organic.id, rank=1),
            DiagnosisTreatment(diagnosis_id=diag1.id, treatment_id=rice_blast_chemical.id, rank=2),
        ])

        # Low-confidence diagnosis awaiting field-worker review
        diag2 = Diagnosis(
            farmer_id=farmer2.id,
            crop_id=jute.id,
            region_id=dinajpur.id,
            confidence=0.52,
            source="online",
            model_version="vision-v0-demo",
            status="NEEDS_REVIEW",
        )
        db.add(diag2)
        db.flush()
        db.add(DiagnosisCandidate(diagnosis_id=diag2.id, disease_id=jute_stem_rot.id, confidence=0.52, rank=1))

        db.commit()
        print("Seeded: 2 regions, 3 crops, 3 diseases, 2 treatments, 2 farmers, 1 field worker, 2 diagnoses.")
    finally:
        db.close()


if __name__ == "__main__":
    run()

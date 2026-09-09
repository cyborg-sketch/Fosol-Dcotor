"""Import every model so Alembic autogenerate (and anything else that needs
the full metadata) can discover them. Never import this from app/models/* —
only from entrypoints like alembic/env.py — or the model imports become
circular.
"""

from app.models.region import Region  # noqa: F401
from app.models.farmer import Farmer, FarmPlot  # noqa: F401
from app.models.crop import Crop  # noqa: F401
from app.models.disease import Disease  # noqa: F401
from app.models.symptom import Symptom  # noqa: F401
from app.models.treatment import Treatment  # noqa: F401
from app.models.diagnosis import Diagnosis, DiagnosisCandidate, DiagnosisTreatment  # noqa: F401
from app.models.field_worker import FieldWorker  # noqa: F401
from app.models.expert_review import ExpertReview  # noqa: F401

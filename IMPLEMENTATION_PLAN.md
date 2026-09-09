# Fasol Doctor — Hackathon Implementation Plan

BRAC IT Code Sprint 2026 · AI Readiness Hackathon
Stack: **Flutter (Android app) + FastAPI (Python backend) + PostgreSQL**
Visual version: https://claude.ai/code/artifact/31ecb241-a25a-494b-ab00-1039ea770745

## 1. Executive Strategy

The objective is not the full production roadmap from the BRD. It is a polished, credible MVP that proves the BRD's core value in a short live demo: a farmer captures a crop photo, speaks in Bangla, receives a diagnosis with a confidence level, gets safe treatment guidance, can operate with poor connectivity, and can escalate uncertain cases to a human field worker.

The BRD requires three coordinated channels — Android-first mobile app, SMS/USSD fallback, and a field-worker console — on top of a computer-vision classifier, Bangla NLP symptom extraction, a treatment recommendation engine, offline capability, confidence-aware escalation, diagnosis history, and an anonymized trend layer. Every choice below is filtered through which of these earns its place in a 72-hour build.

## 2. What to Build for the Hackathon

| Pri | Capability | Hackathon implementation | Demo value |
|---|---|---|---|
| P0 | Farmer mobile diagnosis | Flutter Android app; photo capture/upload; Bangla UI | Core journey |
| P0 | AI diagnosis | Cloud vision model + structured diagnosis service; crop/disease confidence | AI credibility |
| P0 | Bangla voice | Bangla speech-to-text → symptom extraction; text fallback | Accessibility |
| P0 | Treatment | Curated disease→treatment KB + deterministic ranking; LLM only explains | Trust/safety |
| P0 | Low confidence | Threshold → warning → submit to field-worker queue | Differentiator |
| P0 | Offline | Cached disease/treatment data + demo offline path (light model or mocked inference) | BRD alignment |
| P0 | Field worker | Queue → detail → review → resolve workflow | Human-in-loop |
| P1 | History | Farmer diagnosis history, simple cards | Retention |
| P1 | Trend dashboard | Aggregated district/crop/disease counts, seeded demo data | Enterprise value |
| P1 | SMS/USSD | API simulation or provider adapter + demo screen/log | Inclusion |
| P2 | Weather alerts | Not built — shown as roadmap only | Avoid scope creep |
| P2 | Marketplace/e-commerce | Not built | Out of scope |

## 3. Recommended Architecture

A modular monolith, not microservices — interfaces stay clean enough to split later without paying distributed-systems tax during the hackathon.

**Stack: Flutter native Android app + FastAPI backend + PostgreSQL.**

- Flutter gives one team member real camera/microphone/offline-storage control and a genuine installable APK for the demo, rather than a browser shell.
- FastAPI keeps the backend in Python end-to-end — the orchestrator is mostly gluing together AI calls (vision model, STT, LLM symptom extraction), which fits Python's ecosystem and async support better than a JVM stack, and avoids a Java/Python split across the AI pipeline.

```
Flutter App → REST API → Diagnosis Orchestrator
Diagnosis Orchestrator → Image Quality Check → Vision AI → Confidence Engine
Voice/Text → Bangla STT → Symptom Extractor → Diagnosis Orchestrator
Diagnosis → Treatment Knowledge Base → Treatment Ranking → Bangla Explanation
Low confidence → Expert Review Queue → Field Worker Console → Verified Outcome
Diagnosis + anonymized metadata → Analytics Store → Trend Dashboard
```

**Storage:** PostgreSQL holds farmers, crops, diseases, symptoms, diagnoses, treatments, reviews, history, and regions. Uploaded images go to object/local storage — keep analytics free of unnecessary PII.

## 4. AI Stack for Fast Delivery

| Component | Hackathon choice |
|---|---|
| Bangla speech | A managed Bangla-capable STT API to start, behind an adapter so it's swappable later. |
| Bangla NLP | An LLM for symptom extraction, returning strict JSON (crop, symptoms, severity, duration, affected area). BanglaBERT optional for a small classifier/intent layer. |
| Online vision | A vision-capable model for rapid prototype diagnosis, backed by a fixed disease taxonomy. Stronger option: add a specialized EfficientNet classifier for pilot crops. |
| Offline vision | MobileNetV3 / EfficientNet-lite / TFLite on a deliberately small pilot label set (bundled in the Flutter app via `tflite_flutter`). If time runs short, demonstrate cached/common-disease offline behavior rather than faking a full cloud model running on-device. |
| Treatment | The LLM never invents pesticide or dosage advice. Approved treatment records live in the database, get ranked by deterministic rules, and the LLM only translates/explains the approved content in simple Bangla. |
| Confidence | Calculated and normalized in your own FastAPI service. Define a threshold for auto-answer vs. human review, and always show the reason for escalation. |

## 5. Data Model — Minimum

Minimum entities: `Farmer`, `Farm/Plot`, `Crop`, `Disease`, `Symptom`, `Diagnosis`, `DiagnosisCandidate`, `Treatment`, `DiagnosisTreatment`, `ExpertReview`, `FieldWorker`, `Region`, `Consent`, `Notification`, `AuditLog`.

- **Diagnosis** stores: image reference, crop, candidates, confidence, symptoms, treatment snapshot, online/offline source, model/version, status (`AUTO_RESOLVED` / `NEEDS_REVIEW` / `VERIFIED`), timestamps, and region.
- **Treatment** stores: disease, action, category (organic / low-chemical / chemical), cost level, effectiveness evidence/rating, safety notes, availability notes, and approval/version metadata.

Backend: SQLAlchemy models + Alembic migrations against PostgreSQL.

## 6. Core User Journeys

- **A — New farmer:** choose language/phone → choose crop → home → "ছবি তুলে রোগ দেখুন" → camera → image quality → diagnosis → treatment → save history.
- **B — No usable photo:** tap microphone → Bangla speech → symptom summary → diagnosis → treatment.
- **C — Low confidence:** "নিশ্চিত নয়" message → human review request → field-worker queue → farmer receives verified response.
- **D — Offline:** app indicates offline → cached common diseases/treatments → local result or "ইন্টারনেট পেলে বিশেষজ্ঞ যাচাই করুন".
- **E — Field worker:** login → pending cases → farmer/crop context → image/symptoms → AI suggestion → approve/edit → submit verified guidance.
- **F — Admin/BRAC staff:** dashboard → regional disease trend → crop/disease filters → anonymized counts.

## 7. Suggested 72-Hour Execution Plan

| Time | Deliverables |
|---|---|
| 0–4h | Lock scope, repo, environments, DB schema, API contract, UI flow. Select 3–5 pilot crops/disease classes; seed realistic cases. |
| 4–12h | Build Flutter app shell, Bangla design system, home/camera/result/treatment screens. Build FastAPI skeleton, PostgreSQL migrations (SQLAlchemy/Alembic), seed data. |
| 12–24h | Integrate online vision + STT + diagnosis orchestration. Build diagnosis/result APIs. Get one end-to-end happy path working. |
| 24–36h | Build treatment engine, confidence threshold, escalation workflow, history, offline/cache behavior. |
| 36–48h | Build field-worker console and expert review. Build dashboard/trend views. Add SMS/USSD adapter/demo if time permits. |
| 48–60h | Polish UX, Bangla copy, loading/error/empty states, performance, logging, security basics, seed demo data, deploy. |
| 60–72h | Full rehearsal, fix demo blockers, prepare architecture/AI/impact slides, record backup demo video/screenshots. |

## 8. Team Split for 3 People

- **Person 1 — Product/Frontend (Flutter):** mobile farmer flow, Bangla UX, camera/voice UI, history, demo polish.
- **Person 2 — Backend/AI (FastAPI):** REST endpoints, orchestration, AI integrations, confidence engine, treatment service.
- **Person 3 — Data/Platform:** PostgreSQL/seeding, field-worker/admin console (web), offline model/cache, deployment/observability.

All three should jointly own the final demo and pitch — avoid isolated ownership of the happy path.

## 9. Scope Cut Rules

- Do not train a large model from scratch during the hackathon.
- Do not build a real marketplace/e-commerce flow.
- Do not build full weather intelligence.
- Do not integrate every telecom provider — use an adapter/simulator unless a real gateway is already available.
- Do not support dozens of crops — pick a small pilot taxonomy with believable seeded cases.
- Do not expose raw model text directly to farmers — normalize output into your own schema.
- Do not claim benchmark accuracy as real-world accuracy — present pilot validation honestly.
- Do not allow sponsored products to influence diagnosis or treatment ranking.

## 10. Definition of Done

- A judge can open the deployed app and complete the farmer diagnosis journey without developer assistance.
- The main flow is primarily Bangla and uses large, obvious actions with minimal reading.
- At least one image case produces a believable diagnosis and treatment recommendation.
- A Bangla voice case becomes structured symptoms and affects the diagnosis.
- A low-confidence case reaches the field-worker queue and can be verified.
- Offline mode has a real, demonstrable behavior.
- History and an anonymized trend dashboard work with seeded data.
- API, database, AI adapters, and deployment are documented in the repository.
- The team has a backup recorded demo in case live AI/network access fails.

## 11. Final Demo Story

Open with a farmer seeing a diseased leaf. The farmer does not need to know the disease name — they take a photo and speak in Bangla. The system combines image and symptoms, gives a diagnosis with confidence, provides simple treatment steps, and — when uncertain — does not guess: it asks a human field worker to review it. Then briefly show offline behavior and the BRAC regional trend dashboard.

BRD alignment: this plan directly prioritizes the BRD's MVP requirements — photo diagnosis, Bangla voice, treatment guidance, offline operation, SMS/USSD fallback, low-confidence human escalation, history, and regional trend visibility. The full BRD additionally specifies sub-5-second on-device and sub-3-second online response targets, low-literacy Bangla/icon/voice usability, encryption/RBAC, and anonymized analytics — carried forward as post-hackathon hardening, not demo blockers.

---
Source: *Fasol Doctor — Hackathon-First Implementation Plan + Google Stitch UI Prompt*, BRAC IT Code Sprint 2026. Stack revised from the source doc's React/Spring Boot suggestion to Flutter/FastAPI per team decision.

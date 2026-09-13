# Fasol Doctor (ফসল ডাক্তার) — Presentation Script & Demo Guide

**Target Duration:** 3–5 Minutes  
**Format:** Live Screen-Share Presentation (Mobile Emulator / App + Field Worker Web Console)  
**Tone:** Confident, mission-driven, technically rigorous.

---

## 1. Quick Overview: Features to Showcase

| Phase | Screen / Feature | What You Click | Key Message |
| :--- | :--- | :--- | :--- |
| **01** | **Home & Camera Flow** | Tap **"ছবি তুলে রোগ দেখুন"** → Select Crop (e.g., ধান / Rice) → Capture / Upload Leaf Image | Visual AI diagnosis tailored for low-literacy farmers. |
| **02** | **Diagnosis Result & Explainability** | View result screen: 94% Confidence + **"কেন এই রোগ মনে হচ্ছে?"** accordion | AI doesn't just output a label; it explains visual reasoning in Bangla. |
| **03** | **Safe Treatment Engine** | Tap **"চিকিৎসার সহজ পরামর্শ দেখুন"** | **Zero hallucinations:** Deterministic, organic-first treatments curated from agricultural research. |
| **04** | **Voice-First Input (Bangla NLP)** | Go back to Home → Tap **"কথা বলে জানান"** → Record spoken symptoms | Solves low literacy. Bangla speech recognized on-device and matched via **BanglaBERT** semantic embeddings. |
| **05** | **The Differentiator: Human-in-the-Loop** | Trigger low-confidence case (<75%) → Switch to **Field Worker Queue** | If AI is uncertain, it never guesses. It routes the case to human agricultural extension officers. |
| **06** | **Institutional Impact** | Trend Dashboard screen | Aggregated disease outbreak analytics for BRAC and policy makers. |

---

## 2. Word-for-Word Presentation Speech (3 to 4 Minutes)

### [0:00 – 0:30] Hook & The Real-World Problem
> *"Hello everyone and distinguished judges.*
>
> *Every season, smallholder farmers across Bangladesh lose up to 30% of their harvest to preventable crop diseases. When a farmer spots a yellowing leaf or brown lesion, they face two massive barriers: **lack of timely agricultural expertise** and **illiteracy or language barriers**. Today, either they travel miles searching for an extension worker, or they rely on informal shopkeepers who push harmful, expensive chemical pesticides.*
>
> *Meet **Fasol Doctor (ফসল ডাক্তার)** — an AI-powered agricultural copilot that puts expert plant pathology into every farmer’s hands through **visual recognition**, **Bangla voice conversation**, and a **failsafe human-in-the-loop guarantee**."*

---

### [0:30 – 1:15] Feature 1: Photo Diagnosis with Visual AI & Explainability
*(Action: On your mobile screen, start at the Home Screen and click **"ছবি তুলে রোগ দেখুন"**.)*

> *"Let’s walk through the primary farmer journey.*
>
> *The UI is designed specifically for rural usability — large touch targets, minimal text, and clear audio prompts. A farmer selects their crop — say, **Rice (ধান)** — and snaps a photo of the affected leaf.*
>
> *(Action: Tap to capture or upload the infected rice blast leaf. The Analyzing Screen appears briefly.)*
>
> *In under two seconds, our backend model analyzes the image.*
>
> *(Action: The Diagnosis Result screen loads.)*
>
> *Here is the result: **ধানের ব্লাস্ট রোগ (Rice Blast)** with **94% confidence**. Notice three critical design choices here:*
> 1. *First, audio narration: a farmer with low literacy can tap the **‘শুনুন’ (Listen)** button to hear the diagnosis aloud.*
> 2. *Second, **Explainable AI**: below the diagnosis, the farmer can expand **‘কেন এই রোগ মনে হচ্ছে?’ (Why does the AI think so?)**, which highlights the diamond-shaped lesions and current weather humidity factors in plain Bangla.*
> 3. *And third, our model is not a black-box cloud wrapper: it runs on an **EfficientNet-B0 backbone** with an inference head trained directly on plant pathology datasets, scoped specifically to the selected crop."*

---

### [1:15 – 1:55] Feature 2: Safe, Deterministic Treatment Engine
*(Action: Tap **"চিকিৎসার সহজ পরামর্শ দেখুন"** on the Result Screen to open the Treatment Screen.)*

> *"Now comes the most dangerous trap in GenAI for agriculture: **LLM hallucination**. If a model invents chemical proportions or hallucinates an unauthorized pesticide, a farmer’s entire livelihood is destroyed.*
>
> *In Fasol Doctor, **AI is strictly forbidden from inventing treatments**.*
>
> *Instead, our system utilizes a **deterministic treatment engine**. Treatments are curated by agricultural scientists and ranked with a strict policy: **Organic and low-chemical solutions first**, followed by vetted chemical interventions only if severity demands it.*
>
> *Here, the farmer receives step-by-step instructions: isolate infected patches, apply bio-fungicide, and practice regulated irrigation — all numbered, clear, and actionable."*

---

### [1:55 – 2:40] Feature 3: Voice-First Diagnosis using BanglaBERT
*(Action: Navigate back to Home and tap the microphone button **"কথা বলে জানান"**.)*

> *"What happens if a farmer doesn’t have a clear photo, or is working in the field under harsh sunlight?*
>
> *They simply speak.*
>
> *(Action: Tap the pulsing microphone button. Speak or show transcribed text: 'ধানের পাতায় বাদামি চোখের মতো দাগ এবং শীষ শুকিয়ে যাচ্ছে'.)*
>
> *Using on-device Bangla speech recognition (`bn_BD`), speech is transcribed in real-time with an edit fallback. Once submitted, our backend runs **BanglaBERT** (`csebuetnlp/banglabert`). Rather than rigid keyword search, it extracts deep semantic embeddings from the spoken description and matches them against our disease pathology taxonomy via cosine similarity.*
>
> *Even without an image, the farmer gets a grounded diagnostic assessment."*

---

### [2:40 – 3:30] Feature 4: The Game-Changer — Confidence Threshold & Human-in-the-Loop
*(Action: Show a low-confidence diagnosis screen, or switch to the Field Worker queue.)*

> *"Now, let me show you what truly sets Fasol Doctor apart: **Humility in AI**.*
>
> *Most hackathon apps claim 99% accuracy everywhere. In the real world, lighting is bad, leaves overlap, and new disease mutations emerge. If our AI confidence drops below our calibrated threshold of **75%**, it refuses to guess.*
>
> *(Action: Point to the 'NEEDS_REVIEW' / 'পর্যালোচনা প্রয়োজন' banner on the phone.)*
>
> *The app clearly tells the farmer: **'ফলাফল নিশ্চিত নয়' (Not definitively identified)**. Instead of leaving the farmer stranded, the case is automatically dispatched into our **Field Worker Console**.*
>
> *(Action: Switch your screenshare to the Field Worker Queue screen.)*
>
> *BRAC agricultural extension workers can see this queue in real-time. They inspect the farmer's image, see the AI's tentative suggestion, add their expert recommendation, and tap **'অনুমোদন করুন' (Approve & Resolve)**.*
>
> *The farmer receives a push notification with certified human advice. We combine the **speed of AI** with the **safety of human expertise**."*

---

### [3:30 – 4:00] Conclusion & Macro Impact
*(Action: Briefly open the Trend Dashboard screen showing regional stats.)*

> *"Finally, every anonymized diagnosis feeds into our **Regional Trend Dashboard**, allowing BRAC and agricultural officers to spot disease outbreaks in districts like Mymensingh or Rangpur before they become epidemics.*
>
> *To summarize: **EfficientNet-B0** for vision, **BanglaBERT** for voice, **deterministic rules** for safe treatments, and **human-in-the-loop escalation** when certainty is low.*
>
> *Fasol Doctor is not just an AI demo — it is a safe, responsible, and empathetic digital extension worker for 16 million farming families.*
>
> *Thank you, and we welcome your questions!"*

---

## 3. Screen-by-Screen Visual Cue Card

Keep this beside your keyboard during the presentation:

```
[0:00] WebCam / Title Slide
   │
[0:30] Mobile Emulator: Home Screen
   │   └─ Click: "ছবি তুলে রোগ দেখুন"
   ▼
[0:45] Camera Screen
   │   └─ Select: Rice (ধান)
   │   └─ Action: Capture/Upload Image
   ▼
[1:00] Diagnosis Result Screen (High Confidence)
   │   └─ Highlight: 94% score & Audio button
   │   └─ Click: Accordion "কেন এই রোগ মনে হচ্ছে?"
   ▼
[1:25] Treatment Screen
   │   └─ Highlight: Organic-first hierarchy & safe steps
   ▼
[1:55] Voice Screen
   │   └─ Tap: Pulsing Microphone
   │   └─ Highlight: Real-time Bangla transcription & BanglaBERT
   ▼
[2:45] Low Confidence Screen & Field Worker Console
   │   └─ Show: Status "NEEDS_REVIEW"
   │   └─ Switch to: /field-worker/queue
   │   └─ Action: Tap Resolve with notes
   ▼
[3:30] Trend Dashboard & Wrap-up
```

---

## 4. Anticipated Questions from Judges & How to Answer

### Q1: *"How do you handle poor internet connectivity in remote villages?"*
> **Answer:** *"Fasol Doctor has offline resilience built into the architecture. We use **Hive** local storage on the mobile client to cache top regional diseases and organic remedies. If offline, the app provides common cached matches and queues the photo/symptoms to sync automatically once connectivity is restored. Furthermore, our roadmap includes bundling quantized **TFLite** models on-device for basic offline classification."*

### Q2: *"Why not use GPT-4 or Claude directly with a prompt for treatment advice?"*
> **Answer:** *"In agriculture, a hallucinated chemical ratio can burn an entire crop or poison local water tables. Large Language Models are stochastic and prone to confident errors. We strictly separate **Perception** from **Prescription**. AI is used for perception (vision and voice understanding), while prescriptions come from deterministic, curated database records vetted by agricultural scientists."*

### Q3: *"How does the vision model perform on real farmer photos with messy backgrounds?"*
> **Answer:** *"We use an ImageNet-pretrained **EfficientNet-B0** backbone with a specialized linear classification probe. In our training pipeline, we applied heavy image augmentations (random crops, rotation, color jitter, and EXIF orientation normalization) to bridge the gap between clean lab datasets and real-field conditions. And when conditions are genuinely ambiguous, our **75% confidence threshold** triggers human escalation instead of guessing."*

### Q4: *"Why BanglaBERT instead of standard multilingual models?"*
> **Answer:** *"Bangla has rich morphological variations and regional agricultural vocabulary. **BanglaBERT** (developed by BUET) is pre-trained extensively on native Bangla corpora, giving it far superior contextual understanding of agricultural symptoms compared to generic multilingual embeddings."*

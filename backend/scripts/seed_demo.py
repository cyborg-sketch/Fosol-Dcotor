"""Seeds the 11-crop / 38-disease taxonomy matching the labeled dataset in
assets/disease_references/{Train,Val,Test} (see scripts/train_vision_classifier.py and
app/ml_artifacts/labels.json) plus a couple of demo diagnoses, so the field-worker queue
and BRAC trend dashboard have something real to show.

Treatment guidance below is generic, commonly-known agronomic practice for these
well-documented diseases — demo-quality content, not agronomist-verified for local
Bangladesh conditions. Replace with vetted local guidance before any real field use.

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

# Bangla crop names, in the exact English form used as the "<crop> - <disease>" prefix
# in the Train/Val/Test folder names and app/ml_artifacts/labels.json.
CROPS_BN = {
    "Apple": "আপেল",
    "Bell Pepper": "ক্যাপসিকাম",
    "Cherry": "চেরি",
    "Corn (Maize)": "ভুট্টা",
    "Grape": "আঙুর",
    "Peach": "পীচ",
    "Potato": "আলু",
    "Strawberry": "স্ট্রবেরি",
    "Tomato": "টমেটো",
    "Rice": "ধান",
    "Jute": "পাট",
    "Brinjal (Eggplant)": "বেগুন",
}

# (crop_en, disease_suffix_en, name_bn, description_bn, treatments)
# "Healthy" entries get an empty treatments list — no Treatment rows, handled by the
# existing schema/status flow as-is (treatment_engine.rank_treatments just returns []).
DISEASES = [
    ("Apple", "Apple Scab", "আপেলের স্ক্যাব রোগ",
     "পাতা ও ফলে গাঢ় জলপাই-কালো দাগ পড়ে, ছত্রাকঘটিত রোগ।", [
        dict(action_bn="সংক্রমিত ঝরে পড়া পাতা কুড়িয়ে ধ্বংস করুন এবং ডাল ছাঁটাই করে বাতাস চলাচল বাড়ান।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="ছাঁটাইয়ের সময় হাতে গ্লাভস পরুন।"),
        dict(action_bn="ক্যাপটান বা মাইক্লোবিউটানিল ছত্রাকনাশক লেবেলের নির্দেশনা অনুযায়ী স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন ও সুরক্ষা পোশাক পরুন।"),
     ]),
    ("Apple", "Black Rot", "আপেলের কালো পচা রোগ",
     "ফলে ও পাতায় বাদামি-কালো দাগ পড়ে, ফল পচে যায়।", [
        dict(action_bn="মরা ডাল ও মমিফায়েড (শুকিয়ে যাওয়া) ফল ছাঁটাই করে সরিয়ে ফেলুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="ছাঁটাইকৃত অংশ বাগান থেকে দূরে পুড়িয়ে ফেলুন।"),
        dict(action_bn="ক্যাপটান জাতীয় ছত্রাকনাশক নির্দেশিত মাত্রায় প্রয়োগ করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Apple", "Cedar Apple Rust", "আপেলের সিডার মরিচা রোগ",
     "পাতায় উজ্জ্বল কমলা-হলুদ দাগ দেখা যায়।", [
        dict(action_bn="আশেপাশে থাকা সিডার/জুনিপার গাছ (বিকল্প পোষক) থেকে দূরত্ব বজায় রাখুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="প্রয়োজনে স্থানীয় কৃষি অফিসের পরামর্শ নিন।"),
        dict(action_bn="মাইক্লোবিউটানিল ছত্রাকনাশক ফুল ফোটার সময় থেকে নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।"),
     ]),
    ("Apple", "Healthy", "সুস্থ আপেল গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Bell Pepper", "Bacterial Spot", "ক্যাপসিকামের ব্যাকটেরিয়াল স্পট রোগ",
     "পাতা ও ফলে ছোট পানি-ভেজা দাগ পড়ে, পরে বাদামি হয়ে যায়।", [
        dict(action_bn="কপার-বেজড স্প্রে ব্যবহার করুন এবং পাতা ভেজা অবস্থায় জমিতে কাজ এড়িয়ে চলুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।"),
        dict(action_bn="কপার অক্সিক্লোরাইড ও ম্যানকোজেব মিশ্রণ নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Bell Pepper", "Healthy", "সুস্থ ক্যাপসিকাম গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Cherry", "Powdery Mildew", "চেরির পাউডারি মিলডিউ রোগ",
     "পাতায় সাদা গুঁড়োর মতো আস্তরণ পড়ে।", [
        dict(action_bn="সালফার স্প্রে বা বেকিং সোডা দ্রবণ আক্রান্ত পাতায় প্রয়োগ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="রোদের তীব্রতা বেশি থাকলে স্প্রে এড়িয়ে চলুন।"),
        dict(action_bn="মাইক্লোবিউটানিল ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Cherry", "Healthy", "সুস্থ চেরি গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Corn (Maize)", "Cercospora Leaf Spot", "ভুট্টার সারকোস্পোরা পাতা দাগ রোগ",
     "পাতায় লম্বাটে ধূসর-বাদামি দাগ পড়ে।", [
        dict(action_bn="ফসল আবর্তন করুন এবং আক্রান্ত ফসলের অবশিষ্টাংশ মাটিতে চাপা দিন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="অবশিষ্টাংশ পোড়ানোর সময় সাবধানতা অবলম্বন করুন।"),
        dict(action_bn="স্ট্রোবিলুরিন গোত্রের ছত্রাকনাশক প্রয়োজনে নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Corn (Maize)", "Common Rust", "ভুট্টার সাধারণ মরিচা রোগ",
     "পাতায় ছোট ছোট লালচে-বাদামি ফোস্কার মতো দাগ পড়ে।", [
        dict(action_bn="প্রতিরোধী জাত ব্যবহার করুন এবং অতিরিক্ত ঘন বপন এড়িয়ে চলুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="বীজ কেনার সময় প্রতিরোধী জাত সম্পর্কে নিশ্চিত হন।"),
        dict(action_bn="প্রয়োজনে ট্রায়াজোল গোত্রের ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।"),
     ]),
    ("Corn (Maize)", "Northern Leaf Blight", "ভুট্টার নর্দার্ন লিফ ব্লাইট রোগ",
     "পাতায় লম্বা ধূসর-সবুজ চিকন দাগ পড়ে, ধীরে ধীরে বাদামি হয়ে যায়।", [
        dict(action_bn="ফসল আবর্তন করুন এবং প্রতিরোধী জাত রোপণ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত অবশিষ্টাংশ পরবর্তী মৌসুমের আগে সরিয়ে ফেলুন।"),
        dict(action_bn="প্রয়োজনে স্ট্রোবিলুরিন বা ট্রায়াজোল গোত্রের ছত্রাকনাশক স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Corn (Maize)", "Healthy", "সুস্থ ভুট্টা গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Grape", "Black Rot", "আঙুরের কালো পচা রোগ",
     "পাতা ও ফলে বাদামি বৃত্তাকার দাগ পড়ে, ফল শুকিয়ে মমি হয়ে যায়।", [
        dict(action_bn="আক্রান্ত ফল ও পাতা কুড়িয়ে ধ্বংস করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত অংশ বাগান থেকে দূরে সরিয়ে ফেলুন।"),
        dict(action_bn="ম্যানকোজেব ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Grape", "Esca (Black Measles)", "আঙুরের এস্কা রোগ",
     "পাতায় বাঘের ডোরার মতো দাগ পড়ে এবং কাণ্ডে পচন ধরে — কার্যকর রাসায়নিক প্রতিকার নেই, প্রতিরোধই মূল উপায়।", [
        dict(action_bn="আক্রান্ত ডাল ছাঁটাই করে পুড়িয়ে ফেলুন এবং ছাঁটাইয়ের যন্ত্র জীবাণুমুক্ত রাখুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="ছাঁটাইয়ের পর কাটা স্থানে ক্ষত-প্রলেপ ব্যবহার করুন।"),
     ]),
    ("Grape", "Leaf Blight", "আঙুরের পাতা ব্লাইট রোগ",
     "পাতায় বাদামি অনিয়মিত দাগ পড়ে, ধীরে ধীরে ঝরে যায়।", [
        dict(action_bn="আক্রান্ত পাতা অপসারণ করুন এবং গাছের চারপাশে বাতাস চলাচল নিশ্চিত করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="অপসারিত পাতা বাগান থেকে দূরে ফেলুন।"),
        dict(action_bn="ম্যানকোজেব বা কপার-বেজড ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Grape", "Healthy", "সুস্থ আঙুর গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Peach", "Bacterial Spot", "পীচের ব্যাকটেরিয়াল স্পট রোগ",
     "পাতা ও ফলে ছোট গাঢ় দাগ পড়ে, ফল ফেটে যেতে পারে।", [
        dict(action_bn="শীতকালীন সুপ্ত অবস্থায় কপার-বেজড স্প্রে প্রয়োগ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।"),
        dict(action_bn="কপার ও অক্সিটেট্রাসাইক্লিন সমন্বিত স্প্রে নির্দেশিত মাত্রায় ব্যবহার করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Peach", "Healthy", "সুস্থ পীচ গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Potato", "Early Blight", "আলুর আর্লি ব্লাইট রোগ",
     "পাতায় বৃত্তাকার বাদামি দাগ পড়ে, প্রায়ই বলয়াকার (বুলস-আই) প্যাটার্নে।", [
        dict(action_bn="ফসল আবর্তন করুন এবং নিচের আক্রান্ত পাতা অপসারণ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত পাতা মাঠের বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="ক্লোরোথ্যালোনিল বা ম্যানকোজেব ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Potato", "Late Blight", "আলুর লেট ব্লাইট রোগ",
     "পাতায় পানি-ভেজা কালচে দাগ দ্রুত ছড়িয়ে পড়ে — দ্রুত ছড়ানো মারাত্মক রোগ।", [
        dict(action_bn="আক্রান্ত গাছ দ্রুত তুলে ধ্বংস করুন এবং পাতা ভেজা অবস্থায় জমিতে কাজ এড়িয়ে চলুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত গাছ জমি থেকে দূরে পুড়িয়ে ফেলুন।"),
        dict(action_bn="ম্যানকোজেব বা মেটালাক্সিল-জাতীয় ছত্রাকনাশক দ্রুত নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=5,
             safety_notes_bn="উপসর্গ দেখা মাত্র দ্রুত ব্যবস্থা নিন, দেরি করলে পুরো জমি নষ্ট হতে পারে।"),
     ]),
    ("Potato", "Healthy", "সুস্থ আলু গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Strawberry", "Leaf Scorch", "স্ট্রবেরির পাতা স্কর্চ রোগ",
     "পাতায় ছোট বেগুনি-বাদামি দাগ পড়ে, পরে পুরো পাতা শুকিয়ে যায়।", [
        dict(action_bn="ফসল তোলার পর পুরনো ও আক্রান্ত পাতা ছেঁটে ফেলুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="ছাঁটাইকৃত পাতা মাঠের বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="ক্যাপটান বা মাইক্লোবিউটানিল ছত্রাকনাশক প্রয়োজনে নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Strawberry", "Healthy", "সুস্থ স্ট্রবেরি গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Tomato", "Bacterial Spot", "টমেটোর ব্যাকটেরিয়াল স্পট রোগ",
     "পাতা ও ফলে ছোট গাঢ় পানি-ভেজা দাগ পড়ে।", [
        dict(action_bn="কপার-বেজড স্প্রে ব্যবহার করুন এবং বীজ শোধন করে বপন করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।"),
        dict(action_bn="কপার অক্সিক্লোরাইড ও ম্যানকোজেব মিশ্রণ নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Tomato", "Early Blight", "টমেটোর আর্লি ব্লাইট রোগ",
     "নিচের পাতায় বৃত্তাকার বাদামি দাগ পড়ে, বলয়াকার (বুলস-আই) প্যাটার্নে।", [
        dict(action_bn="নিচের আক্রান্ত পাতা অপসারণ করুন এবং মাটিতে মালচিং করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত পাতা মাঠের বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="ক্লোরোথ্যালোনিল বা ম্যানকোজেব ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Tomato", "Late Blight", "টমেটোর লেট ব্লাইট রোগ",
     "পাতা ও কাণ্ডে পানি-ভেজা কালচে দাগ দ্রুত ছড়ায় — দ্রুত ছড়ানো মারাত্মক রোগ।", [
        dict(action_bn="আক্রান্ত গাছ দ্রুত তুলে ধ্বংস করুন এবং ভেজা অবস্থায় গাছ স্পর্শ এড়িয়ে চলুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত গাছ জমি থেকে দূরে পুড়িয়ে ফেলুন।"),
        dict(action_bn="ম্যানকোজেব বা মেটালাক্সিল-জাতীয় ছত্রাকনাশক দ্রুত নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=5,
             safety_notes_bn="উপসর্গ দেখা মাত্র দ্রুত ব্যবস্থা নিন, দেরি করলে পুরো জমি নষ্ট হতে পারে।"),
     ]),
    ("Tomato", "Septoria Leaf Spot", "টমেটোর সেপ্টোরিয়া পাতা দাগ রোগ",
     "নিচের পাতায় ছোট ছোট গোলাকার ধূসর দাগ পড়ে, কালো প্রান্তসহ।", [
        dict(action_bn="নিচের আক্রান্ত পাতা অপসারণ করুন এবং মাটিতে মালচিং করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত পাতা মাঠের বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="ক্লোরোথ্যালোনিল ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Tomato", "Yellow Leaf Curl Virus", "টমেটোর হলুদ পাতা কোঁকড়ানো ভাইরাস রোগ",
     "পাতা ছোট, হলুদাভ ও কোঁকড়ানো হয়ে যায় — সাদা মাছি বাহক, ভাইরাসের সরাসরি চিকিৎসা নেই।", [
        dict(action_bn="আক্রান্ত গাছ তুলে ফেলুন এবং হলুদ আঠালো ফাঁদ দিয়ে সাদা মাছি নিয়ন্ত্রণ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত গাছ জমি থেকে দূরে সরিয়ে ফেলুন।"),
        dict(action_bn="সাদা মাছি (ভাইরাসের বাহক) দমনে ইমিডাক্লোপ্রিড জাতীয় কীটনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=3,
             safety_notes_bn="এটি ভাইরাসের সরাসরি চিকিৎসা নয়, শুধু বাহক পোকা নিয়ন্ত্রণ করে।"),
     ]),
    ("Tomato", "Healthy", "সুস্থ টমেটো গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Rice", "Bacterial Leaf Blight", "ধানের ব্যাকটেরিয়াল লিফ ব্লাইট রোগ",
     "পাতার কিনারা থেকে হলুদ-বাদামি হয়ে শুকিয়ে যায়, ব্যাকটেরিয়াঘটিত রোগ।", [
        dict(action_bn="সুষম সার প্রয়োগ করুন (অতিরিক্ত নাইট্রোজেন এড়িয়ে চলুন) এবং জমির পানি নিষ্কাশন ব্যবস্থা ঠিক রাখুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত জমির পানি অন্য জমিতে যেতে দেবেন না।"),
        dict(action_bn="কপার অক্সিক্লোরাইড বা স্ট্রেপ্টোসাইক্লিন-জাতীয় ব্যাকটেরিয়ানাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Rice", "Brown Spot", "ধানের বাদামি দাগ রোগ",
     "পাতা ও ধানের দানায় ছোট বাদামি ডিম্বাকার দাগ পড়ে, ছত্রাকঘটিত রোগ।", [
        dict(action_bn="সুষম সার (বিশেষত পটাশ) প্রয়োগ করুন এবং বীজ শোধন করে বপন করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="বীজ শোধনের সময় হাত-মুখ ঢেকে রাখুন।"),
        dict(action_bn="ম্যানকোজেব বা প্রোপিকোনাজল ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Rice", "Healthy Rice Leaf", "সুস্থ ধান গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),
    ("Rice", "Leaf Blast", "ধানের ব্লাস্ট রোগ",
     "ছত্রাকের আক্রমণে পাতায় চোখের মতো দাগ ও শীষ শুকিয়ে যাওয়া।", [
        dict(action_bn="নিমতেল স্প্রে সপ্তাহে ২ বার আক্রান্ত জমিতে প্রয়োগ করুন।",
             category="organic", cost_level=1, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার সময় হাত-মুখ ঢেকে রাখুন।"),
        dict(action_bn="ট্রাইসাইক্লাজল ছত্রাকনাশক — প্যাকেটের নির্দেশনা অনুযায়ী মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=5,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Rice", "Leaf scald", "ধানের পাতা স্কাল্ড রোগ",
     "পাতার আগা থেকে লম্বাটে জোনযুক্ত বাদামি দাগ পড়ে শুকিয়ে যায়।", [
        dict(action_bn="সুষম সার প্রয়োগ করুন এবং আক্রান্ত পাতা অপসারণ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত পাতা জমির বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="প্রোপিকোনাজল ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Rice", "Sheath Blight", "ধানের শীথ ব্লাইট রোগ",
     "কাণ্ডের গোড়ার আবরণে (শীথে) সবুজ-ধূসর দাগ পড়ে উপরের দিকে ছড়ায়।", [
        dict(action_bn="ঘন বপন এড়িয়ে চলুন এবং জমিতে পানি নিয়ন্ত্রণ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="সারিবদ্ধভাবে বপন করলে বাতাস চলাচল ভালো হয়।"),
        dict(action_bn="হেক্সাকোনাজল ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),

    ("Jute", "Cescospora Leaf Spot", "পাটের সারকোস্পোরা পাতা দাগ রোগ",
     "পাতায় ছোট ছোট কৌণিক বাদামি দাগ পড়ে, ছত্রাকঘটিত রোগ।", [
        dict(action_bn="আক্রান্ত পাতা অপসারণ করুন এবং ফসল আবর্তন করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত পাতা জমির বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="ম্যানকোজেব ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Jute", "Golden Mosaic", "পাটের গোল্ডেন মোজাইক ভাইরাস রোগ",
     "পাতায় হলুদ-সবুজ মোজাইক প্যাটার্নের দাগ পড়ে — সাদা মাছি বাহক, ভাইরাসের সরাসরি চিকিৎসা নেই।", [
        dict(action_bn="আক্রান্ত গাছ তুলে ফেলুন এবং হলুদ আঠালো ফাঁদ দিয়ে সাদা মাছি নিয়ন্ত্রণ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত গাছ জমি থেকে দূরে সরিয়ে ফেলুন।"),
        dict(action_bn="সাদা মাছি (ভাইরাসের বাহক) দমনে ইমিডাক্লোপ্রিড জাতীয় কীটনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=3,
             safety_notes_bn="এটি ভাইরাসের সরাসরি চিকিৎসা নয়, শুধু বাহক পোকা নিয়ন্ত্রণ করে।"),
     ]),
    ("Jute", "Healthy", "সুস্থ পাট গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),

    ("Brinjal (Eggplant)", "Fruit & Shoot Borer", "বেগুনের ডগা ও ফল ছিদ্রকারী পোকা",
     "কচি ডগা নেতিয়ে পড়ে এবং ফলে ছিদ্র দেখা যায়, মারাত্মক ক্ষতিকারক পোকা।", [
        dict(action_bn="সেক্স ফেরোমন ফাঁদ ব্যবহার করুন এবং আক্রান্ত ডগা ও ফল কেটে মাটিতে পুঁতে ফেলুন।",
             category="organic", cost_level=1, effectiveness_rating=4,
             safety_notes_bn="সপ্তাহে অন্তত দুইবার আক্রান্ত ডগা ও ফল সংগ্রহ করে ধ্বংস করুন।"),
        dict(action_bn="স্পাইনোস্যাড বা এমামেকটিন বেনজোয়েট অনুমোদিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="রাসায়নিক প্রয়োগের সময় নিরাপত্তা সরঞ্জাম ব্যবহার করুন এবং ফসল তোলার নির্ধারিত সময় মেনে চলুন।"),
     ]),
    ("Brinjal (Eggplant)", "Bacterial Wilt", "বেগুনের ব্যাকটেরিয়াজনিত ঢলে পড়া রোগ",
     "সবুজ অবস্থাতেই পুরো গাছ হঠাৎ নেতিয়ে শুকিয়ে মারা যায়, ব্যাকটেরিয়াঘটিত রোগ।", [
        dict(action_bn="আক্রান্ত গাছ তুলে ধ্বংস করুন, প্রতিরোধী জাত চাষ করুন এবং বুনো তিতবেগুনের সাথে গ্রাফটিং করুন।",
             category="organic", cost_level=1, effectiveness_rating=4,
             safety_notes_bn="আক্রান্ত গাছ জমি থেকে দূরে পুড়িয়ে ফেলুন।"),
        dict(action_bn="ব্লিচিং পাউডার দিয়ে জমি শোধন করুন (প্রতি শতকে ১২০ গ্রাম)।",
             category="chemical", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="বীজ বা চারা রোপণের পূর্বে জমিতে প্রয়োগ করুন।"),
     ]),
    ("Brinjal (Eggplant)", "Phomopsis Blight", "বেগুনের ফোমোপসিস ব্লাইট রোগ",
     "পাতা ও ফলে বৃত্তাকার পচা দাগ পড়ে এবং ফল পচে যায়, ছত্রাকঘটিত রোগ।", [
        dict(action_bn="আক্রান্ত ফল ও পাতা সংগ্রহ করে ধ্বংস করুন এবং সুষম সার প্রয়োগ করুন।",
             category="organic", cost_level=1, effectiveness_rating=3,
             safety_notes_bn="আক্রান্ত অংশ জমির বাইরে সরিয়ে ফেলুন।"),
        dict(action_bn="কার্বেনডাজিম বা ম্যানকোজেব ছত্রাকনাশক নির্দেশিত মাত্রায় স্প্রে করুন।",
             category="chemical", cost_level=2, effectiveness_rating=4,
             safety_notes_bn="স্প্রে করার আগে প্যাকেটের নির্দেশনা পড়ুন।"),
     ]),
    ("Brinjal (Eggplant)", "Healthy", "সুস্থ বেগুন গাছ", "কোনো রোগের লক্ষণ পাওয়া যায়নি।", []),
]


def run():
    db = SessionLocal()
    try:
        existing_regions = {r.district: r for r in db.query(Region).all()}
        rangpur = existing_regions.get("রংপুর") or Region(district="রংপুর", upazila="মিঠাপুকুর")
        dinajpur = existing_regions.get("দিনাজপুর") or Region(district="দিনাজপুর", upazila="বিরল")
        new_regions = [r for r in [rangpur, dinajpur] if not r.id]
        if new_regions:
            db.add_all(new_regions)
            db.flush()

        existing_crops = {c.name_en: c for c in db.query(Crop).all()}
        crops = {}
        for name_en, name_bn in CROPS_BN.items():
            if name_en in existing_crops:
                crops[name_en] = existing_crops[name_en]
            else:
                c = Crop(name_en=name_en, name_bn=name_bn)
                db.add(c)
                crops[name_en] = c
        db.flush()

        existing_diseases = {d.name_en: d for d in db.query(Disease).all()}
        diseases: dict[str, Disease] = {}
        treatments_by_disease: dict[str, list[Treatment]] = {}
        for crop_en, disease_suffix_en, name_bn, description_bn, treatment_specs in DISEASES:
            full_name_en = f"{crop_en} - {disease_suffix_en}"
            if full_name_en in existing_diseases:
                disease = existing_diseases[full_name_en]
            else:
                disease = Disease(crop_id=crops[crop_en].id, name_en=full_name_en, name_bn=name_bn, description_bn=description_bn)
                db.add(disease)
            diseases[full_name_en] = disease
            treatments_by_disease[full_name_en] = treatment_specs
        db.flush()

        existing_treatments = {t.disease_id for t in db.query(Treatment).all()}
        treatment_rows = []
        for full_name_en, specs in treatments_by_disease.items():
            d = diseases[full_name_en]
            if d.id not in existing_treatments:
                for spec in specs:
                    treatment_rows.append(Treatment(disease_id=d.id, approved=True, **spec))
        if treatment_rows:
            db.add_all(treatment_rows)
            db.flush()

        farmer1 = db.query(Farmer).filter(Farmer.phone == "+8801710000001").first()
        if not farmer1:
            farmer1 = Farmer(phone="+8801710000001", name="রহমত আলী", region_id=rangpur.id)
            db.add(farmer1)
        farmer2 = db.query(Farmer).filter(Farmer.phone == "+8801710000002").first()
        if not farmer2:
            farmer2 = Farmer(phone="+8801710000002", name="সালমা বেগম", region_id=dinajpur.id)
            db.add(farmer2)
        db.flush()

        field_worker = db.query(FieldWorker).filter(FieldWorker.phone == "+8801910000001").first()
        if not field_worker:
            field_worker = FieldWorker(name="কৃষি কর্মকর্তা - রংপুর", phone="+8801910000001", region_id=rangpur.id)
            db.add(field_worker)
            db.flush()

        db.commit()
        print(
            f"Seeded: {len(crops)} crops, {len(diseases)} diseases, "
            f"{len(treatment_rows)} treatments."
        )
    finally:
        db.close()


if __name__ == "__main__":
    run()

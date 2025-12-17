import io
import base64
import sqlite3
from datetime import datetime
from fastapi import FastAPI, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from PIL import Image
import numpy as np
import tensorflow as tf
from openai import OpenAI
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import requests

# -----------------------------------------------------
# CONFIGURACIONES
# -----------------------------------------------------

import pickle
import numpy as np
from datetime import datetime


app = FastAPI()
#client = OpenAI(api_key="YOUR_OPENAI_API_KEY")

MODEL_PATH = "model/cnn_moodmirror_64px_50dataset.h5"
IMG_SIZE = (64, 64)

# Cargar modelo CNN
cnn_model = tf.keras.models.load_model(MODEL_PATH)

# Clases originales
CLASS_LABELS = {0: "Angry", 1: "Happy", 2: "Neutral", 3: "Sad", 4: "Surprise"}


TEXT_MODEL_PATH = "model/emotion_xlmr"

text_tokenizer = AutoTokenizer.from_pretrained(TEXT_MODEL_PATH)
text_model = AutoModelForSequenceClassification.from_pretrained(TEXT_MODEL_PATH)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
text_model.to(device)
text_model.eval()

id2label = text_model.config.id2label
label2spanish = text_model.config.label2spanish


# DB SQLite
conn = sqlite3.connect("db.sqlite3", check_same_thread=False)
cur = conn.cursor()

cur.execute("""
    CREATE TABLE IF NOT EXISTS entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        text_note TEXT,
        image_emotion TEXT,
        text_emotion TEXT,
        advice TEXT
    )
""")
conn.commit()

# -----------------------------------------------------
# UTILIDAD: convertir imagen a tensor
# -----------------------------------------------------
def preprocess_image(file: UploadFile):
    img = Image.open(file.file).convert("RGB")
    img = img.resize(IMG_SIZE)
    arr = np.array(img) / 255.0
    arr = np.expand_dims(arr, axis=0)
    return arr

# -----------------------------------------------------
# UTILIDAD: análisis del texto con OpenAI (sentiment)
# -----------------------------------------------------
def analyze_text_emotion(text: str):
    inputs = text_tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        padding=True
    )

    inputs = {k: v.to(device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = text_model(**inputs)
        logits = outputs.logits

    pred_id = logits.argmax(dim=1).item()
    pred_label = id2label[str(pred_id)] if isinstance(id2label, dict) else id2label[pred_id]
    pred_es = label2spanish[pred_label]

    return pred_label, pred_es, torch.softmax(logits, dim=1).cpu().numpy()[0]


# -----------------------------------------------------
# UTILIDAD: generar el consejo con peso 70% texto / 30% imagen
# -----------------------------------------------------

'''
def generate_advice(text_emotion, image_emotion, note):
    prompt = f"""
    Eres un diario emocional. Debes dar un consejo breve y empático.

    Peso del análisis:
    - 70% basado en el texto
    - 30% basado en la emoción detectada en la imagen

    Emoción por texto: {text_emotion}
    Emoción por imagen: {image_emotion}

    Nota del usuario: "{note}"

    Genera un consejo corto y útil que levante el ánimo.
    """

    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}]
    )

    return resp.choices[0].message.content.strip()
'''

def generate_advice(text_emotion, image_emotion, note):
    prompt = f"""
Eres un diario emocional. Da un consejo breve y empático.

Peso del análisis:
- 70% emoción del texto
- 30% emoción de la imagen

Emoción texto: {text_emotion}
Emoción imagen: {image_emotion}

Nota del usuario:
"{note}"

Consejo:
"""

    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "gemma:3b",
            "prompt": prompt,
            "stream": False
        },
        timeout=60
    )

    return response.json()["response"].strip()

    
EMOTIONS = ["Angry", "Happy", "Neutral", "Sad", "Surprise"]
emotion2id = {e: i for i, e in enumerate(EMOTIONS)}


def update_transition_matrix(stats):
    counts = stats["transition_counts"]
    row_sums = counts.sum(axis=1, keepdims=True)

    matrix = np.divide(
        counts,
        row_sums,
        where=row_sums != 0
    )

    with open("model/emotion_transition_matrix.pkl", "wb") as f:
        pickle.dump({
            "matrix": matrix,
            "emotion2id": emotion2id
        }, f)
def update_transition_matrix(stats):
    counts = stats["transition_counts"]
    row_sums = counts.sum(axis=1, keepdims=True)

    matrix = np.divide(
        counts,
        row_sums,
        where=row_sums != 0
    )

    with open("model/emotion_transition_matrix.pkl", "wb") as f:
        pickle.dump({
            "matrix": matrix,
            "emotion2id": emotion2id
        }, f)

import json

def generate_insights(stats):
    insights = []

    for day, emotions in stats["day_counts"].items():
        total = sum(emotions.values())
        if total < 3:
            continue

        dominant = max(emotions, key=emotions.get)
        prob = emotions[dominant] / total

        if prob > 0.45:
            insights.append(
                f"Los {day.lower()} tiendes a sentirte más {dominant.lower()}."
            )

    counts = stats["transition_counts"]
    for i, from_emotion in enumerate(EMOTIONS):
        row = counts[i]
        total = row.sum()
        if total < 3:
            continue

        j = int(np.argmax(row))
        prob = row[j] / total

        if prob > 0.4 and i != j:
            insights.append(
                f"Después de sentirte {from_emotion.lower()}, normalmente pasas a estar {EMOTIONS[j].lower()}."
            )

    with open("model/emotion_insights.json", "w", encoding="utf-8") as f:
        json.dump(insights, f, ensure_ascii=False, indent=2)


def update_emotion_models(date_str, current_emotion):
    with open("model/emotion_stats.pkl", "rb") as f:
        stats = pickle.load(f)

    day = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S").strftime("%A")
    stats["day_counts"][day][current_emotion] += 1

    last = stats["last_emotion"]
    if last is not None:
        i = emotion2id[last]
        j = emotion2id[current_emotion]
        stats["transition_counts"][i, j] += 1

    stats["last_emotion"] = current_emotion

    with open("model/emotion_stats.pkl", "wb") as f:
        pickle.dump(stats, f)

    update_transition_matrix(stats)
    generate_insights(stats)


# -----------------------------------------------------
# ENDPOINT: registrar entrada diaria
# -----------------------------------------------------

@app.post("/add_entry")
async def add_entry(
    photo: UploadFile,
    text: str = Form(...)
):
    # --- 1. procesar imagen ---
    img_arr = preprocess_image(photo)
    pred = cnn_model.predict(img_arr)[0]   # vector de 5 clases
    emotion_img = CLASS_LABELS[np.argmax(pred)]

    # --- 2. sentimiento por texto ---
    emotion_text_en, emotion_text_es, text_scores = analyze_text_emotion(text)
    TEXT_TO_APP_EMOTION = {
    "anger": "Angry",
    "joy": "Happy",
    "sadness": "Sad",
    "neutral": "Neutral",
    "surprise": "Surprise",
    "fear": "Sad",
    "disgust": "Angry"
    }
    emotion_text = TEXT_TO_APP_EMOTION[emotion_text_en]


    # --- 3. generar consejo ---
    advice = generate_advice(emotion_text, emotion_img, text)

    # --- 4. guardar en SQLite ---
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cur.execute("""
        INSERT INTO entries (date, text_note, image_emotion, text_emotion, advice)
        VALUES (?, ?, ?, ?, ?)
    """, (now, text, emotion_img, emotion_text, advice))
    conn.commit()
    update_emotion_models(now, emotion_text)

    # --- 5. retornar JSON completo ---
    return {
        "date": now,
        "text_note": text,
        "image": {
            "emotion": emotion_img,
            "scores": pred.tolist()  # probabilidades
        },
        "text": {
            "emotion": emotion_text
        },
        "advice": advice
    }

# -----------------------------------------------------
# ENDPOINT: eliminar entrada por ID
# -----------------------------------------------------
@app.delete("/delete_entry/{entry_id}")
def delete_entry(entry_id: int):
    cur.execute("DELETE FROM entries WHERE id = ?", (entry_id,))
    conn.commit()
    return {"status": "ok", "id": entry_id}


# -----------------------------------------------------
# ENDPOINT: obtener todas las entradas
# -----------------------------------------------------
@app.get("/entries")
def list_entries():
    cur.execute("SELECT * FROM entries ORDER BY date DESC")
    rows = cur.fetchall()

    result = []
    for r in rows:
        result.append({
            "id": r[0],
            "date": r[1],
            "text_note": r[2],
            "image_emotion": r[3],
            "text_emotion": r[4],
            "advice": r[5]
        })
    return result


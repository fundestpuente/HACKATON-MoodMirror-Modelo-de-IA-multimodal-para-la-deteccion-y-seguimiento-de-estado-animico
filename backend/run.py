import pickle
import os
import numpy as np

EMOTIONS = ["Angry", "Happy", "Neutral", "Sad", "Surprise"]
DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

if not os.path.exists("model/emotion_stats.pkl"):
    stats = {
        "day_counts": {d: {e: 0 for e in EMOTIONS} for d in DAYS},
        "transition_counts": np.zeros((len(EMOTIONS), len(EMOTIONS))),
        "last_emotion": None
    }

    with open("model/emotion_stats.pkl", "wb") as f:
        pickle.dump(stats, f)

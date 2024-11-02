# evaluation.py
import pandas as pd
import pickle
from sklearn.metrics import classification_report, accuracy_score

# Load the preprocessed data
feedback_df = pd.read_csv('processed_feedback.csv')

# Load the trained model and vectorizer
with open('sentiment_model.pkl', 'rb') as f:
    model = pickle.load(f)

with open('tfidf_vectorizer.pkl', 'rb') as f:
    tfidf = pickle.load(f)

# Prepare the test data
X = feedback_df['ProcessedSatisfaction']
y = feedback_df['SentimentLabel']
X_tfidf = tfidf.transform(X)

# Predict on the test data
y_pred = model.predict(X_tfidf)

# Evaluate the model
print("Accuracy:", accuracy_score(y, y_pred))
print("Classification Report:\n", classification_report(y, y_pred))

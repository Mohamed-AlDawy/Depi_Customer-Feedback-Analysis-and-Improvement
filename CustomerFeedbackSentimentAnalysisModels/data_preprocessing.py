# data_preprocessing.py
import pandas as pd
import spacy

# Load the SpaCy English model
nlp = spacy.load("en_core_web_sm")

# Preprocess function using SpaCy for tokenization and lemmatization
def preprocess_text(text):
    doc = nlp(text)
    tokens = [token.lemma_ for token in doc if not token.is_stop and not token.is_punct]
    return " ".join(tokens)

# Load your CSV file
feedback_df = pd.read_csv('CleanedSatisfactionData.csv')

# Clean and preprocess the 'satisfaction' column (assuming it's the text data for analysis)
feedback_df['ProcessedSatisfaction'] = feedback_df['satisfaction'].apply(preprocess_text)

# Save the processed data for model training
feedback_df.to_csv('processed_feedback.csv', index=False)
print("Text preprocessing completed!")

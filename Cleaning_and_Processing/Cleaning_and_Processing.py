import pandas as pd
import os
import pyodbc
import re
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer




# Download NLTK resources for sentiment analysis
nltk.download('punkt')
nltk.download('vader_lexicon')

# Step 1: Connect to Azure SQL Database
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=azsqldbtestserver.database.windows.net;'
    'DATABASE=DepiProjectDB;'
    'UID=sqladmin;'
    'PWD=DepiProject123'
)

# Step 2: Load data from the Bronze Layer (CustomerProfile_Staging table)
query = "SELECT * FROM CustomerProfile_Staging"
feedback_df = pd.read_sql(query, conn)

# Step 3: Data Cleaning
# Handling missing values (fill NaNs with 0)
feedback_df.fillna(0, inplace=True)

# Convert Age to integer (coerce errors and replace them with 0)
feedback_df['Age'] = pd.to_numeric(feedback_df['Age'], errors='coerce').fillna(0).astype(int)

# Convert categorical columns to category data type
feedback_df['Gender'] = feedback_df['Gender'].astype('category')
feedback_df['Customer Type'] = feedback_df['Customer Type'].astype('category')
feedback_df['Class'] = feedback_df['Class'].astype('category')

# Step 4: Text Cleaning for Sentiment Analysis
def clean_text(text):
    text = re.sub(r'\W', ' ', text)  # Remove non-word characters
    text = text.lower()  # Convert to lowercase
    text = re.sub(r'\s+', ' ', text).strip()  # Remove extra spaces
    return text

# Apply text cleaning to the 'satisfaction' column
feedback_df['CleanedSatisfaction'] = feedback_df['satisfaction'].apply(clean_text)

# Step 5: Sentiment Analysis using NLTK's VADER
# Initialize VADER sentiment analyzer
sid = SentimentIntensityAnalyzer()

# Function to calculate sentiment score
def analyze_sentiment(text):
    sentiment_score = sid.polarity_scores(text)
    return sentiment_score['compound']  # Compound score is the normalized sentiment score

# Apply sentiment analysis to the cleaned satisfaction text
feedback_df['SentimentScore'] = feedback_df['CleanedSatisfaction'].apply(analyze_sentiment)

# Assign sentiment labels based on the sentiment score
def label_sentiment(score):
    if score > 0.05:
        return 'Positive'
    elif score < -0.05:
        return 'Negative'
    else:
        return 'Neutral'

# Apply sentiment labeling
feedback_df['SentimentLabel'] = feedback_df['SentimentScore'].apply(label_sentiment)

# Step 6: Save the cleaned and processed data into the Silver Layer (CustomerProfile_Cleaned table)
feedback_df.to_sql('CustomerProfile_Cleaned', conn, if_exists='replace', index=False)

# Close the database connection
conn.close()

print("Data cleaning, sentiment analysis, and saving to SQL completed successfully!")


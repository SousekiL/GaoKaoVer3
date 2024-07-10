# give me a case using nlp model
from textblob import TextBlob

# Define the text you want to analyze
text = "I love this place! Everyone is so welcoming and kind."

# Create a TextBlob object
blob = TextBlob(text)

# Print sentiment polarity (-1 to 1)
print("Sentiment Polarity:", blob.sentiment.polarity)

# Print sentiment subjectivity (0 to 1)
print("Sentiment Subjectivity:", blob.sentiment.subjectivity)


#%%

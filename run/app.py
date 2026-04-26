#imports 
from flask import Flask, jsonify
from google.cloud import storage

app = Flask(__name__)

#connect to storage
client = storage.Client()

#chooses our bucket
BUCKET_NAME = "food-logs"

#This is set to the home root
@app.route("/")
def count_files():
    #connecting to bucket
    bucket = client.get_bucket(BUCKET_NAME)
    #get a list of all files stored in the bucket
    blobs = list(bucket.list_blobs())

  #Returns the bucket name and number of logs as a JSON
    return jsonify({
        "bucket": BUCKET_NAME,
        "Number of logs": len(blobs)
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

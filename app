#imports
from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os

import firebase_admin
from firebase_admin import credentials, auth

from google.cloud import storage
from google.oauth2 import service_account

app = Flask(__name__)
CORS(app)

#This key allows the server to authenticate users through firebase
cred = credentials.Certificate("/home/lasterau/firebase-key.json")
firebase_admin.initialize_app(cred)

gcs_credentials = service_account.Credentials.from_service_account_file(
    "/home/lasterau/key.json"
)

#sets storage_client to my project
storage_client = storage.Client(
    project="semester-project-laster",
    credentials=gcs_credentials
)

#connects to my bucket where logs will be stored
BUCKET_NAME = "food-logs"
bucket = storage_client.bucket(BUCKET_NAME)

#verifies the users token
def verify_token():
    auth_header = request.headers.get("Authorization")

    #if theres no token the user is not logged in
    if not auth_header:
        return None

    #This asks firebase to verify the token
    try:
        token = auth_header.split("Bearer ")[-1]
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    #handles the exception if the token is invalid 
    except Exception as e:
        print("Auth error:", e)
        return None

#This can be used to see if the flask is running by looking at the VMS public IP
@app.route('/')
def home():
    return "Food Logger API is running!"

# This is the post route for saving logs 
@app.route('/log', methods=['POST'])
def log_food():
    user_data = verify_token()

    #If verified we get the email if not the user email is set to guest
    if not user_data:
        user_email = "guest"
    else:
        user_email = user_data.get("email", "unknown")

    #gets the data from the users POST
    data = request.json

    #makes a dict of the POST
    new_entry = {
        "user": user_email,
        "food": data.get("food"),
        "calories": data.get("calories")
    }

    #Names the log based on how many are in the bucket already
    filename = f"log_{len(list(bucket.list_blobs()))}.json"

    blob = bucket.blob(filename)

    #uploads the log to the bucket as a json file 
    blob.upload_from_string(json.dumps(new_entry), content_type="application/json")

    #returns a success message after the log is finished
    return jsonify({
        "message": "Food logged!",
        "entry": new_entry
    })

#This allows you to send a get request to see the logs 
@app.route('/logs', methods=['GET'])
def get_logs():
    logs = []

    #This loops through all logs in the bucket and returns them
    for blob in bucket.list_blobs():
        data = blob.download_as_text()
        logs.append(json.loads(data))

    return jsonify(logs)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

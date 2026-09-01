from app.consume_queue import consume_and_store_order
from app.orders import Base

from sqlalchemy import create_engine
from flask import Flask, jsonify
from waitress import serve

import os
import threading


BILLING_DB_USER = os.getenv("BILLING_DB_USER")
BILLING_DB_PASSWORD = os.getenv("BILLING_DB_PASSWORD")
BILLING_DB_NAME = os.getenv("BILLING_DB_NAME")
BILLING_APP_PORT = os.getenv("BILLING_APP_PORT", "8080")

DB_URI = (
    "postgresql://"
    f'{BILLING_DB_USER}:{BILLING_DB_PASSWORD}'
    f'@billing-db:5432/{BILLING_DB_NAME}'
)

engine = create_engine(DB_URI)
Base.metadata.create_all(engine)

# Start queue consumer in a background thread
consumer_thread = threading.Thread(
    target=consume_and_store_order,
    args=(engine,),
    daemon=True
)
consumer_thread.start()

# Create Flask app
app = Flask(__name__)

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify(status="healthy"), 200

# Start the server
serve(app, listen=f"*:{BILLING_APP_PORT}")

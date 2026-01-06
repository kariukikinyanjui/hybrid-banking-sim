from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/api/balance")
def bal():
    # Simulating a COBOL Core Banking response
    return jsonify({
        "account": "1234567890",
        "balance": 50000.00,
        "currency": "KES",
        "status": "ACTIVE",
        "system": "MAINFRAME-V2"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

import os
import redis
from flask import Flask

app = Flask(__name__)

redis_host = os.environ.get("REDIS_HOST", "localhost")
redis_port = int(os.environ.get("REDIS_PORT", 6379))

cache = redis.Redis(host=redis_host, port=redis_port)

def get_visit_count():
    try:
        count = cache.incr("visits")
        return count
    except redis.exceptions.ConnectionError:
        return "unavailable"

@app.route("/")
def home():
    count = get_visit_count()
    return f"Hello from Docker! Visit count: {count}", 200

@app.route("/health")
def health():
    return {"status": "ok"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
from flask import Flask
from prometheus_client import start_http_server, Counter, generate_latest

# Query counter
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests')

app = Flask(__name__)

@app.route('/')
def hello_world():
    REQUEST_COUNT.inc() # Increase the counter with each query
    return 'Hello, CloudForge!'

@app.route('/metrics')
def metrics():
    return generate_latest()

if __name__ == '__main__':
    # Run the metric server for Prometheus on a separate port
    start_http_server(8000)
    # Launch the app
    app.run(host='0.0.0.0', port=8080)
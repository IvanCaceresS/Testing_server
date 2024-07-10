from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, World!"

@app.route('/api', methods=['GET'])
def api():
    data = {
        'message': 'Hello from the API',
        'status': 'success'
    }
    return jsonify(data)

@app.route('/api/data', methods=['POST'])
def post_data():
    received_data = request.get_json()
    response = {
        'message': 'Data received',
        'data': received_data
    }
    return jsonify(response), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

from flask import Flask
import os

app = Flask(__name__)

# TEST, trigger a build
@app.route('/')
def hello_world():
    region = os.environ.get('REGION', 'unknown region')
    return f'Hello, World! From {region} 🎉'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
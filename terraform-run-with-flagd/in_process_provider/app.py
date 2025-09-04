import atexit
import os

from flask import Flask
from openfeature import api
from openfeature.contrib.provider.flagd import FlagdProvider
from openfeature.contrib.provider.flagd.config import ResolverType

# similar to saas-runtime: https://cloud.google.com/saas-runtime/docs/flags/flags-standalone-quickstart.md
flags_file_path = os.path.join(os.path.dirname(__file__), "flags.json")
print(f"current file path: {os.path.dirname(__file__)}")
print(f"flags file path: {flags_file_path}")

api.set_provider(FlagdProvider(
    resolver_type=ResolverType.FILE,
    offline_flag_source_path=flags_file_path,
))

# Ensure the provider is shut down gracefully on application exit.
atexit.register(api.shutdown)

app = Flask(__name__)


@app.route("/")
def hello_world():
    """Returns a simple Hello World message."""
    client = api.get_client()
    welcome_message = client.get_string_value("welcome-message", "Default message")
    return f"The flag value is: {welcome_message}"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
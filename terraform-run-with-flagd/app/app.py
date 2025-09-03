import os
from flask import Flask
from openfeature import api
from openfeature.contrib.provider.flagd import FlagdProvider
from openfeature.contrib.provider.flagd.config import ResolverType

# similar to saasruntime: https://cloud.google.com/saas-runtime/docs/flags/flags-standalone-quickstart.md

# by default -> localhost:8013
api.set_provider(FlagdProvider(
    resolver_type=ResolverType.IN_PROCESS,
    # we can also provide a offline file path
))

app = Flask(__name__)


@app.route("/")
def hello_world():
    """Returns a simple Hello World message."""
    client = api.get_client()
    is_new_feature_enabled = client.get_boolean_value("new-feature", False)

    if is_new_feature_enabled:
        return "Hello, World from Cloud Run! (New Feature Enabled)"
    else:
        return "Hello, World from Cloud Run!"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
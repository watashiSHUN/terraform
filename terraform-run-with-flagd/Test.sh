# 1. Run simple test
curl -X GET "https://flask-hello-world-49654637999.us-central1.run.app" -H "Authorization: bearer $(gcloud auth print-identity-token)"

# Change the flag

# reupload to blob
cd flag
gcloud storage cp demo.flagd.json gs://shun-feature-flags-bucket-12345/demo.flagd.json
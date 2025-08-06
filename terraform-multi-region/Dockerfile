# Use the official Python base image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the app directory into the container's /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code to current directory
COPY app/ .

# Expose the port that the Flask app will listen on
# Cloud Run expects the application to listen on the port specified by the PORT environment variable
ENV PORT 8080
EXPOSE ${PORT}

# Run the Flask application with Gunicorn
# main.py -> flask python file
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]
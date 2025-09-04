# Use an official Python runtime as a parent image.
# Using a slim image keeps the final image size smaller.
FROM python:3.11-slim

# Set environment variables to improve Python's behavior in a container.
# 1. Prevents Python from writing .pyc files to disk.
# 2. Ensures that container logs are sent straight to the terminal without being buffered.
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the port the application will listen on. This is the default for Cloud Run.
ENV PORT 8080

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt.
# --no-cache-dir: Disables the cache, which is not needed in a container image.
# --upgrade pip: Ensures we have the latest version of pip.
RUN pip install --no-cache-dir --upgrade pip -r requirements.txt

# Copy the rest of the application's code into the container at /app
COPY . .

# Expose the port the app runs on.
EXPOSE 8080

# Run the web service on container startup using gunicorn.
# This is a production-ready WSGI server.
CMD exec gunicorn --bind :${PORT} --workers 1 --threads 8 --timeout 0 app:app
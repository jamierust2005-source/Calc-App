# Base image with Python installed
FROM python:3.11-slim as base

# Set working directory
WORKDIR /app

# Copy the calculator script into the container
COPY calculator.py /app/

# Set the entrypoint to run the calculator script
# The default entrypoint expects the user to pass the --operation and numbers
ENTRYPOINT ["python", "calculator.py"]
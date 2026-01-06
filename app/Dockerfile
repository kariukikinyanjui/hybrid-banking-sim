# 1. Base Image: Use a lightweight Python version to keep image size small (~100MB)
FROM python:3.9-slim

# 2. Environment Variables
# PYTHONUNBUFFERED=1: Ensures logs stream instantly to your terminal (vital for debugging k8s)
ENV PYTHONUNBUFFERED=1

# 3. Work Directory
WORKDIR /app

# 4. Install Dependencies
# We copy ONLY requirements first to cache this layer. 
# If you change code but not requirements, Docker skips this slow step.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy Code
COPY . .

# 6. Runtime Command
# Bind to 0.0.0.0 so external traffic (from the Load Balancer) can reach it.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "wallet_project.wsgi:application"]

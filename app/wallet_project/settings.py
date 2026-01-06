import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.environ.get('SECRET_KEY', 'insecure-dev-key')
DEBUG = True
ALLOWED_HOSTS = ['*'] # In K8s, the LoadBalancer IP changes, so we allow all for now.

INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.auth',
    'wallet_app', # Our custom app
]

MIDDLEWARE = [
    'django.middleware.common.CommonMiddleware',
]

ROOT_URLCONF = 'wallet_project.urls'

# --- THE DATABASE CONFIGURATION (Critical for RDS) ---
# We do NOT hardcode IP addresses. We read from the environment.
# Kubernetes will inject these values later.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'walletdb'),
        'USER': os.environ.get('DB_USER', 'admin_user'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'SuperSecurePass123!'),
        'HOST': os.environ.get('DB_HOST', 'localhost'), # This will be the RDS Endpoint
        'PORT': '5432',
    }
}

WSGI_APPLICATION = 'wallet_project.wsgi.application'
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_TZ = True

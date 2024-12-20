#!/bin/bash

# Exit script on any error
set -e

# Project variables
PROJECT_NAME="five_star_hotel_pms"
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"
DATABASE_NAME="pms_db"
DATABASE_USER="pms_user"
DATABASE_PASSWORD="securepassword"

echo "Generating complete repo structure for $PROJECT_NAME..."

# Update system packages and install dependencies
echo "Updating system packages and installing dependencies..."
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git nodejs npm postgresql postgresql-contrib

# Create project directory
mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Initialize Git repository
echo "Initializing Git repository..."
git init

# Create .gitignore file
echo "Creating .gitignore..."
cat <<EOL > .gitignore
# Python
*.pyc
__pycache__/
venv/

# Node
node_modules/

# Environment variables
.env
EOL

# Backend setup
echo "Setting up Django backend..."
mkdir $BACKEND_DIR && cd $BACKEND_DIR
python3 -m venv venv
source venv/bin/activate
pip install django djangorestframework psycopg2-binary django-cors-headers
django-admin startproject backend .
# Create default apps
python manage.py startapp reservations
python manage.py startapp rooms
python manage.py startapp guests
python manage.py startapp payments

# Update settings.py for database and installed apps
echo "Updating Django settings.py..."
cat <<EOL >> backend/settings.py

# Add custom apps
INSTALLED_APPS += [
    'reservations',
    'rooms',
    'guests',
    'payments',
    'rest_framework',
    'corsheaders',
]

# Middleware for CORS
MIDDLEWARE.insert(0, 'corsheaders.middleware.CorsMiddleware')

# Database configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '$DATABASE_NAME',
        'USER': '$DATABASE_USER',
        'PASSWORD': '$DATABASE_PASSWORD',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

# CORS settings
CORS_ALLOW_ALL_ORIGINS = True
EOL

# Migrate database
echo "Migrating database..."
python manage.py makemigrations
python manage.py migrate

deactivate
cd ..

# Frontend setup
echo "Setting up React.js frontend..."
mkdir $FRONTEND_DIR && cd $FRONTEND_DIR
npx create-react-app .
npm install axios react-router-dom

# Create folders for components, pages, and services
mkdir -p src/components src/pages src/services

# Sample API service file
echo "Creating sample API service file..."
cat <<EOL > src/services/api.js
import axios from 'axios';

const API = axios.create({
  baseURL: 'http://localhost:8000/api',
});

export default API;
EOL

cd ..

# Create README.md
echo "Creating README.md..."
cat <<EOL > README.md
# $PROJECT_NAME

## Description
This is a Five-Star Hotel Property Management System built with Django (backend) and React.js (frontend).

## Features
- Reservation Management
- Room Management
- Guest Services
- Payment Integration

## Setup Instructions
1. **Backend**:
   - Navigate to the \`$BACKEND_DIR\` directory.
   - Activate the virtual environment: \`source venv/bin/activate\`.
   - Run the server: \`python manage.py runserver\`.

2. **Frontend**:
   - Navigate to the \`$FRONTEND_DIR\` directory.
   - Start the development server: \`npm start\`.

## Environment Variables
Store the following in a \`.env\` file:
- DATABASE_NAME
- DATABASE_USER
- DATABASE_PASSWORD
EOL

# Final message
echo "Repository for $PROJECT_NAME is ready!"
echo "Navigate to $PROJECT_NAME and start development."

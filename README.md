# Python project with MySQL and Nginx deployment example

This project is a full-stack Python application designed for testing deployment on an Nginx server with a MySQL database.

## Features
- Python + Flask backend
- HTML/CSS frontend
- MySQL integration
- Nginx reverse proxy example
- Docker and Docker Compose support
- CRUD project dashboard

## Project structure
- `app.py` – Flask application
- `templates/` – HTML pages
- `static/css/` – styling
- `database/init.sql` – MySQL schema
- `nginx.conf` – Nginx reverse proxy config
- `docker-compose.yml` – local deployment stack
- `Dockerfile` – app container setup

## Quick start with Docker

1. Clone the repository.
2. Create a `.env` file from `.env.example` if needed.
3. Run:

```bash
docker-compose up --build
```

4. Open the app in your browser:
- http://localhost
- or http://localhost:5000 if you are running the app directly

## Run locally without Docker

1. Install dependencies:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

2. Start MySQL and create a database named `projectdb`.
3. Configure environment variables in a `.env` file.
4. Run:

```bash
python app.py
```

## MySQL connection

The app expects the following environment variables:
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`

## Sample project structure

This app lets you add, view, and delete project records, which are stored in a MySQL table called `projects`.

## Nginx hosting

The included `nginx.conf` demonstrates a reverse proxy setup pointing to the Flask service inside Docker. This is useful for testing how the app behaves when hosted behind Nginx.

## Notes
- For production deployments, use a strong secret key and secure environment configuration.
- You can extend the app with authentication, users, and advanced dashboards.

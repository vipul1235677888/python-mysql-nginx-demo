from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "supersecretkey")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", "rootpass"),
    "database": os.getenv("DB_NAME", "projectdb"),
    "autocommit": True,
    "charset": "utf8mb4",
}


def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


def init_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS projects (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(150) NOT NULL,
            description TEXT,
            status VARCHAR(50) DEFAULT 'Open',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    cursor.execute("SELECT COUNT(*) FROM projects")
    if cursor.fetchone()[0] == 0:
        sample_projects = [
            ("Website Redesign", "Revamp the company landing page UI", "In Progress"),
            ("CRM Integration", "Connect CRM with the sales dashboard", "Open"),
            ("Mobile App Launch", "Prepare launch checklist for the mobile release", "Completed"),
        ]
        cursor.executemany(
            "INSERT INTO projects (title, description, status) VALUES (%s, %s, %s)",
            sample_projects,
        )
    conn.close()


@app.route("/")
def index():
    init_db()
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id, title, description, status, created_at FROM projects ORDER BY created_at DESC"
    )
    projects = cursor.fetchall()
    conn.close()
    return render_template("index.html", projects=projects)


@app.route("/add", methods=["GET", "POST"])
def add_project():
    if request.method == "POST":
        title = request.form.get("title", "").strip()
        description = request.form.get("description", "").strip()
        status = request.form.get("status", "Open").strip()

        if not title:
            flash("Project title is required.")
            return redirect(url_for("add_project"))

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO projects (title, description, status) VALUES (%s, %s, %s)",
            (title, description, status),
        )
        conn.close()
        flash("Project added successfully.")
        return redirect(url_for("index"))

    return render_template("add_project.html")


@app.route("/delete/<int:project_id>", methods=["POST"])
def delete_project(project_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM projects WHERE id = %s", (project_id,))
    conn.close()
    flash("Project deleted successfully.")
    return redirect(url_for("index"))


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)

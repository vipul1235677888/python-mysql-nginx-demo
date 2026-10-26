#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# PYTHON PROJECT DEPLOYMENT SCRIPT
# Ubuntu + Nginx + Gunicorn + GitHub
# ==========================================

# -------- PROJECT CONFIGURATION --------

APP_DIR="/var/www/python-project/pythonmy-mysql-nginx-demo"
BRANCH="main"
SERVICE_NAME="python-project"
VENV_DIR="$APP_DIR/venv"
REQUIREMENTS_FILE="$APP_DIR/requirements.txt"

# -------- LOGGING --------

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

fail() {
    log "ERROR: $*"
    exit 1
}

# -------- ERROR HANDLING --------

trap 'fail "Deployment failed near line $LINENO. Check the logs above."' ERR

# -------- VALIDATE USER --------

if [[ "$EUID" -eq 0 ]]; then
    fail "Do not run this script using sudo. Run it as the project owner."
fi

# -------- CHECK PROJECT DIRECTORY --------

[[ -d "$APP_DIR" ]] || fail "Project directory not found: $APP_DIR"

cd "$APP_DIR"

log "Starting deployment..."

# -------- CHECK GIT --------

command -v git >/dev/null 2>&1 || fail "Git is not installed."

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || fail "This directory is not a Git repository."

# -------- CHECK REQUIRED FILES --------

[[ -f "$REQUIREMENTS_FILE" ]] \
    || fail "requirements.txt not found."

[[ -x "$VENV_DIR/bin/python" ]] \
    || fail "Virtual environment not found. Create it first."

[[ -x "$VENV_DIR/bin/pip" ]] \
    || fail "pip not found in the virtual environment."

# -------- CHECK WORKING TREE --------

if [[ -n "$(git status --porcelain)" ]]; then
    fail "Uncommitted changes detected. Commit, stash, or safely resolve them first."
fi

# -------- FETCH GITHUB CHANGES --------

log "Fetching latest code from GitHub..."

git fetch origin "$BRANCH"

# -------- VERIFY REMOTE BRANCH --------

git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" \
    || fail "Remote branch origin/$BRANCH was not found."

# -------- UPDATE APPLICATION CODE --------

log "Updating project from branch $BRANCH..."

git pull --ff-only origin "$BRANCH"

# -------- INSTALL DEPENDENCIES --------

log "Installing Python dependencies..."

"$VENV_DIR/bin/python" -m pip install \
    -r "$REQUIREMENTS_FILE"

# -------- CHECK PYTHON SYNTAX --------

log "Checking Python syntax..."

"$VENV_DIR/bin/python" -m compileall -q \
    -x '(^|/)(venv|\.git|__pycache__)(/|$)' \
    "$APP_DIR"

# -------- RESTART APPLICATION --------

log "Restarting application service..."

sudo -n /usr/bin/systemctl restart "$SERVICE_NAME"

# -------- VERIFY APPLICATION --------

if ! sudo -n /usr/bin/systemctl is-active --quiet "$SERVICE_NAME"; then
    sudo /usr/bin/systemctl status "$SERVICE_NAME" --no-pager || true
    fail "Application service did not start successfully."
fi

# -------- CHECK NGINX --------

if ! sudo -n /usr/sbin/nginx -t; then
    fail "Nginx configuration test failed."
fi

# -------- COMPLETED --------

log "Deployment completed successfully."
log "Service: $SERVICE_NAME"
log "Branch: $BRANCH"
log "Check your website to verify the changes."

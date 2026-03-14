# NolePark Full-Stack Project (Flask + Vue 3)

Built with **Python 3.14** and **Vue 3**.

---

## Global Prerequisites
Every teammate must install these two managers.

### Windows (PowerShell)
* **Install uv:** `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"`
* **Install Bun:** `powershell -c "irm bun.sh/install.ps1 | iex"`

### macOS / Linux (Terminal)
* **Install uv:** `curl -LsSf https://astral.sh/uv/install.sh | sh`
* **Install Bun:** `curl -fsSL https://bun.sh/install | bash`

*Note: Restart your terminal after installing.*

---

## Backend Setup (Flask)
**Tech:** Python 3.14 + uv

1. **Navigate:** `cd backend`
2. **Sync:** `uv sync` (This auto-downloads Python 3.14 and all libs).

**VS Code Setup:** Press `Ctrl+Shift+P` -> `Python: Select Interpreter` -> Select the one inside `backend/.venv`.

---

## Frontend Setup (Vue)
**Tech:** Vue 3 + Bun + TypeScript + Vite

1. **Navigate:** `cd frontend`
2. **Install:** `bun install` (Uses `bun.lockb` for 100% team consistency).

---

## Database Setup (PostgreSQL)
**Tech:** PostgreSQL + Docker Engine

1. **Navigate:** Run from project root directory `NolePark`
2. **Run:** `docker compose up -d` (reads `docker-compose.yml` and initializes the docker container)

---

## Team Workflow Rules

1. **Python Packages:** Use `uv add <name>`. Never use pip directly.
2. **Frontend Packages:** Use `bun add <name>`. Never use npm/yarn.
3. **Git Etiquette:** * Always commit `uv.lock` and `bun.lockb`.
   * Never commit `.venv/` or `node_modules/`.
4. **Formatting:** We use **Oxfmt** (Rust-speed formatting). Install the **OXC** extension in VS Code to ensure your code matches the team's style on every save.

---
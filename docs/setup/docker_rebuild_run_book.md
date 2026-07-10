# Docker Rebuild Runbook

## For Docker AI Assistant Projects

This document provides a repeatable process for rebuilding a Docker-based application after code, configuration, dependency, or container changes.

---

## 1. Prerequisites

Ensure:

- Docker Desktop is running
- You are in the project root
- The project contains:

```text
Dockerfile
docker-compose.yml
requirements.txt
requirements-dev.txt
app/
tests/
```

Run:

```bash
pwd
ls -la
```

Verify that `docker-compose.yml` exists in the current directory. 【1-6805c0】【2-dc0ff4】

---

## 2. Stop Existing Containers

Before rebuilding, stop any currently running containers.

```bash
docker compose down
```

Verify:

```bash
docker compose ps
```

Expected result:

```text
No running services
```

This is also useful when resolving port conflicts. 【2-dc0ff4】

---

## 3. Validate the Compose Configuration

Ensure Docker Compose can successfully parse the configuration.

```bash
docker compose config
```

Expected result:

```text
Resolved configuration displayed
```

If errors occur, fix them before rebuilding. 【3-d81143】【4-2bfd7b】

---

## 4. Rebuild Docker Images

## Standard Rebuild

```bash
docker compose build
```

Use this after:

- Python code changes
- Markdown/documentation changes
- Configuration updates

---

## Clean Rebuild (Recommended)

Use when:

- Requirements files changed
- Dockerfile changed
- Build cache appears corrupted

```bash
docker compose build --no-cache
```

This forces Docker to rebuild all layers from scratch. 【1-6805c0】【5-11b62a】【4-2bfd7b】

---

## 5. Start the Application

Run:

```bash
docker compose up -d
```

Verify:

```bash
docker compose ps
```

Expected result:

```text
NAME      STATUS
app       Up
```

【2-dc0ff4】【3-d81143】

---

## 6. View Container Logs

Check startup messages.

```bash
docker compose logs --tail 100
```

Or:

```bash
docker compose logs -f
```

Expected result:

```text
Application started successfully
```

【2-dc0ff4】【3-d81143】

---

## 7. Validate the Running Application

## FastAPI Example

Open:

```text
http://localhost:8000
```

Expected response:

```json
{
  "status": "running"
}
```

【6-e52763】

---

## API Test Example

```bash
curl \
"http://localhost:8000/ask?question=Hello"
```

Expected:

```json
{
  "question": "Hello",
  "answer": "..."
}
```

【6-e52763】

---

## 8. Run Tests Inside Docker

Run pytest from inside the container.

```bash
docker compose run --rm app pytest
```

Alternative:

```bash
docker compose run --rm app python -m pytest
```

Expected:

```text
PASSED
```

【6-e52763】【4-2bfd7b】

---

## 9. Full Recovery Rebuild

Use when Docker behaves unexpectedly.

## Stop everything

```bash
docker compose down
```

## Remove unused containers

```bash
docker container prune
```

## Rebuild from scratch

```bash
docker compose build --no-cache
```

## Start again

```bash
docker compose up -d
```

## Validate

```bash
docker compose ps

docker compose logs --tail 100
```

【2-dc0ff4】

---

## 10. Diagnose Port 8000 Conflicts

If you see:

```text
Address already in use
```

Find the process:

```bash
lsof -i :8000
```

View running containers:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Stop containers:

```bash
docker compose down
```

Remove unused containers:

```bash
docker container prune
```

【2-dc0ff4】

---

## 11. Validation Checklist

Run:

```bash
docker compose config
docker compose build --no-cache
docker compose up -d
docker compose ps
docker compose logs --tail 100
docker compose run --rm app pytest
```

Success criteria:

- Docker Compose resolves successfully
- Image builds without errors
- Container starts correctly
- Application responds on localhost
- Tests pass

【1-6805c0】【5-11b62a】【4-2bfd7b】

---

## Quick Rebuild Commands

```bash
cd ~/Projects/personal/ai-lab/docker_ai_assistant

docker compose down

docker compose build --no-cache

docker compose up -d

docker compose ps

docker compose logs --tail 100

docker compose run --rm app pytest
```

This is the recommended rebuild workflow for the Docker AI Assistant project. 【1-6805c0】【6-e52763】

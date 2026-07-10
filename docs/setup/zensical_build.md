# Zensical Rebuild and Start Runbook

**Project:** Docker AI Assistant
**Purpose:** Rebuild the Zensical documentation site and start the local preview server.

---

## Prerequisites

Ensure:

- Zensical is installed
- `mkdocs.yml` exists in the project root
- `docs/` contains your Markdown documentation
- You are in the project root directory

Verify:

```bash
pwd
ls -la
```

Expected files:

```text
mkdocs.yml
docs/
.gitignore
README.md
```

---

## Step 1 – Navigate to the Project

```bash
cd ~/Projects/personal/ai-lab/docker_ai_assistant
```

Verify:

```bash
pwd
```

Expected:

```text
.../docker_ai_assistant
```

---

## Step 2 – Check for Port 8000 Conflicts

If you've recently run:

```bash
zensical serve
```

or a FastAPI application, port 8000 may already be in use.

Check:

```bash
lsof -i :8000
```

Example:

```text
Python 57150 smeek TCP localhost:8000 (LISTEN)
```

If a process is using the port:

```bash
kill 57150
```

Verify:

```bash
lsof -i :8000
```

Expected:

```text
(no output)
```

---

## Step 3 – Remove Existing Generated Site

Remove the current build.

```bash
rm -rf site
```

Verify:

```bash
ls -la
```

The `site` directory should no longer exist.

---

## Step 4 – Validate Configuration

Check the configuration file.

```bash
cat mkdocs.yml
```

Confirm:

```yaml
site_name: Docker AI Assistant

docs_dir: docs

theme:
  name: material
```

Important:

- Use spaces only
- Do not use tabs

Check for tabs:

```bash
cat -te mkdocs.yml
```

If you see:

```text
^I
```

replace with spaces.

---

## Step 5 – Rebuild Documentation

Generate a new documentation site.

```bash
zensical build
```

Expected:

```text
Build completed successfully
```

Verify:

```bash
ls -la site
```

Expected:

- `index.html` exists
- other generated site files are present

---

## Step 6 – Start Local Preview Server

Serve the site locally for preview.

```bash
zensical serve
```

Open the browser at:

```text
http://127.0.0.1:8000
```

If port 8000 is still busy, stop the process and retry.

---

## Notes

- If `zensical` is not found, ensure your Python environment is active.
- If `mkdocs.yml` is invalid, fix the YAML indentation and retry.

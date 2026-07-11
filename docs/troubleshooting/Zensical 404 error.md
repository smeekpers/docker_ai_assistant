# Zensical 404 Error Troubleshooting Guide

**Project:** Docker AI Assistant
**Error:** Documentation site returns a 404 page

---

## Symptom

When opening the documentation site, you see:

```text
404 - Page Not Found
```

or Zensical displays its default 404 page instead of the expected documentation.

---

## Environment

```text
Project: docker_ai_assistant
Documentation Tool: Zensical
Configuration File: mkdocs.yml
Documentation Source: docs/
Generated Site: site/
```

---

## Current Configuration

The current `mkdocs.yml` configuration is:

```yaml
site_name: Docker AI Assistant

docs_dir: docs

theme:
  name: material

nav:
  - Home: index.md
  - Architecture:
      - Overview: architecture.md
  - Setup:
      - Deployment: setup/deployment.md
      - Docker:
          - Rebuild Run Book: setup/docker_rebuild_run_book.md
          - Docker Setup: setup/docker.md
      - GitHub: setup/github.md
      - Zensical Rebuild and Start: setup/zensical_build.md
  - Testing:
      - Testing Guide: testing.md
  - Troubleshooting:
      - Zensical 404 Error: troubleshooting/Zensical 404 error.md
      - Docker Errors: troubleshooting/docker-errors.md
      - FastAPI Errors: troubleshooting/fastapi-errors.md
      - Git Errors: troubleshooting/git-errors.md
```

---

## Root Cause Analysis

A 404 error is commonly caused by one or more of the following:

### Missing Markdown Files

The navigation references:

```yaml
index.md
architecture.md
setup/deployment.md
setup/docker.md
setup/docker_rebuild_run_book.md
setup/github.md
setup/zensical_build.md
testing.md
troubleshooting/Zensical 404 error.md
troubleshooting/docker-errors.md
troubleshooting/fastapi-errors.md
troubleshooting/git-errors.md
```

If any file is missing from `docs/`, the corresponding page cannot be generated.

---

## Documentation Not Rebuilt

Changes to Markdown files are not reflected until the site is rebuilt.

A stale or incomplete `site/` folder can result in missing pages.

---

## Invalid Navigation Paths

If the filename in `mkdocs.yml` does not exactly match the filename in `docs/`, the page may not exist.

Example:

```yaml
- Zensical Rebuild and Start: setup/zensical_build.md
```

but the file is:

```text
docs/setup/zensical_rebuild_start.md
```

This will generate a problem.

---

## Old Generated Site

The generated site may contain outdated content.

If pages were removed or renamed, old generated files might still exist.

---

## Diagnostic Checks

### Check Documentation Files

Run:

```bash
find docs -type f | sort
```

Expected:

```text
docs/index.md
docs/architecture.md
docs/setup/deployment.md
docs/setup/docker.md
docs/setup/docker_rebuild_run_book.md
docs/setup/github.md
docs/setup/zensical_build.md
docs/testing.md
docs/troubleshooting/Zensical 404 error.md
docs/troubleshooting/docker-errors.md
docs/troubleshooting/fastapi-errors.md
docs/troubleshooting/git-errors.md
```

---

## Check Home Page

Verify:

```bash
ls -la docs/index.md
```

Expected:

```text
docs/index.md
```

---

## Check Configuration

Display the configuration:

```bash
cat mkdocs.yml
```

Verify:

- filenames match exactly
- correct indentation
- no tabs

---

## Check for Tabs

```bash
cat -te mkdocs.yml
```

Bad:

```text
^I
```

Good:

```text
spaces only
```

---

## Fix Procedure

### Step 1 – Stop Existing Server

Check port usage:

```bash
lsof -i :8000
```

If a process exists:

```bash
kill <PID>
```

---

## Step 2 – Remove Existing Build

```bash
rm -rf site
```

---

## Step 3 – Rebuild Documentation

```bash
zensical build
```

Expected:

```text
Build completed successfully
```

---

## Step 4 – Verify Output

```bash
ls -la site
```

Expected:

```text
index.html
search.json
sitemap.xml
```

---

## Step 5 – Restart Server

```bash
source .venv/bin/activate
./scripts/serve_zensical.sh
```

Expected:

```text
Serving ... on http://localhost:8000
```

---

## Step 6 – Open Browser

```bash
open http://localhost:8000
```

---

## Create Missing Files

If any pages are missing, create them.

## Home Page

```bash
cat > docs/index.md <<'EOF'
# Docker AI Assistant

Welcome to the project documentation.
EOF
```

## Architecture

```bash
cat > docs/architecture.md <<'EOF'
# Architecture

Application architecture documentation.
EOF
```

## Setup

```bash
cat > docs/setup.md <<'EOF'
# Setup

Project setup instructions.
EOF
```

## Testing

```bash
cat > docs/testing.md <<'EOF'
# Testing

Project testing instructions.
EOF
```

## Deployment

```bash
cat > docs/deployment.md <<'EOF'
# Deployment

Deployment instructions.
EOF
```

## Troubleshooting

```bash
cat > docs/troubleshooting.md <<'EOF'
# Troubleshooting

Common issues and resolutions.
EOF
```

---

## Validation Checklist

Run:

```bash
find docs -type f | sort

cat mkdocs.yml

rm -rf site

zensical build

zensical serve
```

Success criteria:

- All Markdown files exist
- Configuration loads correctly
- Site builds successfully
- `site/index.html` exists
- Browser opens without a 404 page

---

## Quick Recovery Commands

```bash
cd ~/Projects/personal/ai-lab/docker_ai_assistant

find docs -type f | sort

rm -rf site

zensical build

lsof -i :8000

zensical serve
```

---

## Best Practice

Keep under source control:

```text
docs/
mkdocs.yml
```

Ignore generated output:

```text
site/
```

in `.gitignore` to avoid Git and pre-commit issues.

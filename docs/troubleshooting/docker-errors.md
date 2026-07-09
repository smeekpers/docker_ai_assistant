# Docker Dev Container Troubleshooting

## Quick Diagnostic Checklist
From your project root, run:

```sh
pwd
ls -la .devcontainer
cat .devcontainer/devcontainer.json
docker ps
docker context ls
docker compose config
```

These are the exact diagnostics recommended in the Dev Container troubleshooting guide.

## Verify `devcontainer.json`
Your documented working example uses:

```json
{
  "name": "Docker Python Template",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/app",
  "shutdownAction": "stopCompose"
}
```

Key checks:
- `dockerComposeFile` points to the correct file
- `service` matches the service name in `docker-compose.yml`
- `workspaceFolder` matches the mounted path (`/app`)

## Validate Docker Compose
Run:

```sh
docker compose config
```

If this fails, VS Code Dev Containers will also fail. Validate compose before reopening the container.

## Check the Container Stays Running
If VS Code builds the container but cannot attach, run:

```sh
docker compose ps
docker compose logs app --tail=100
```

A container that exits immediately prevents VS Code from attaching. A common development workaround is to use a long-running command such as:

```yaml
command: sleep infinity
```

## Rebuild the Dev Container
Use the VS Code command palette:

```text
Cmd+Shift+P
Dev Containers: Rebuild Container
```

or:

```text
Dev Containers: Rebuild and Reopen in Container
```

These are the recommended recovery actions after fixing configuration problems.

## Reset Everything
For this project, the recommended reset sequence is:

```sh
docker compose down
docker compose build --no-cache
docker compose up
```

Then reopen the Dev Container.

## Verify the Environment After Attachment
Once attached, confirm the runtime environment:

```sh
pwd
which python
python --version
pip list | grep pytest
```

Confirm:
- Workspace is `/app`
- Python is inside the container
- `pytest` is installed

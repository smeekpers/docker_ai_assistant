# Testing

## Run Unit Tests

```bash
docker compose run --rm app pytest
```

## Run Coverage

```bash
docker compose run --rm app \
  pytest --cov=app
```

## Expected Result

```text
All tests pass.
Coverage exceeds 80%.
```

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_ask_uses_mocked_ai_response(monkeypatch):
    def fake_ask_ai(question: str) -> str:
        return f"Mock answer for: {question}"

    monkeypatch.setattr("app.main.ask_ai", fake_ask_ai)

    response = client.post(
        "/ask",
        json={"question": "What is Docker?"},
    )

    assert response.status_code == 200
    assert response.json()["answer"] == "Mock answer for: What is Docker?"

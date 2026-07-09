from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_check_returns_running_status():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {"status": "running"}


def test_ask_endpoint_returns_mocked_answer(monkeypatch):
    def fake_ask_ai(question: str) -> str:
        return f"Mocked answer for: {question}"

    monkeypatch.setattr("app.main.ask_ai", fake_ask_ai)

    response = client.get("/ask", params={"question": "Explain Docker"})

    assert response.status_code == 200
    assert response.json() == {
        "question": "Explain Docker",
        "answer": "Mocked answer for: Explain Docker",
    }

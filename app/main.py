from fastapi import FastAPI

from app.ai_client import ask_ai

app = FastAPI()


@app.get("/")
def root():
    return {"status": "running"}


@app.get("/health")
def health():
    return {"status": "running"}


@app.get("/ask")
def ask(question: str):
    answer = ask_ai(question)

    return {
        "question": question,
        "answer": answer,
    }

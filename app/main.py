from fastapi import FastAPI
from pydantic import BaseModel

from app.ai_client import ask_ai

app = FastAPI()


class AskRequest(BaseModel):
    question: str


@app.get("/")
def root():
    return {"status": "running"}


@app.get("/health")
def health():
    return {"status": "running"}


@app.post("/ask")
def ask(request: AskRequest):

    answer = ask_ai(request.question)

    return {
        "question": request.question,
        "answer": answer,
    }

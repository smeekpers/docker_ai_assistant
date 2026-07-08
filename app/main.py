from fastapi import FastAPI
from pydantic import BaseModel

from app.ai_service import ask_ai

app = FastAPI()


class Question(BaseModel):
    question: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/ask")
def ask(question: Question):

    response = ask_ai(question.question)

    return {"answer": response}

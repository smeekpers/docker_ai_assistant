from openai import OpenAI

client = OpenAI()


def ask_ai(question: str) -> str:
    response = client.responses.create(model="gpt-5.5", input=question)

    return response.output_text

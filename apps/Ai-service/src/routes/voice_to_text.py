from fastapi import APIRouter, File, UploadFile
from dotenv import load_dotenv
from agents.voice_to_text_agent import question_asker_agent 
from model.voice_to_text import voice_to_text_agent_state
import os
import google.generativeai as genai
from fastapi import  UploadFile, File
genai.configure(api_key="your-api-key-here")
model = genai.GenerativeModel("gemini-1.5-flash")
import requests
import time
from io import BytesIO
from agents.voice_to_text_agent import State

voice_to_text_router = APIRouter(
    prefix="/voice_to_text",
    tags=["voice_to_text"]
)

load_dotenv()

def rev_transcribe_bytes(api_key, audio_bytes):

    # Wrap bytes in BytesIO
    audio_file = BytesIO(audio_bytes)

    # Create job
    job = requests.post(
        "https://api.rev.ai/speechtotext/v1/jobs",
        headers={"Authorization": f"Bearer {api_key}"},
        files={"media": ("audio.mp3", audio_file)},  # name + file-like object
        data={"language": "en"}
    ).json()

    job_id = job["id"]

    # Wait for completion
    status = "in_progress"
    while status not in ["transcribed", "failed"]:
        time.sleep(5)
        status = requests.get(
            f"https://api.rev.ai/speechtotext/v1/jobs/{job_id}",
            headers={"Authorization": f"Bearer {api_key}"}
        ).json()["status"]

    # Get transcript
    transcript = requests.get(
        f"https://api.rev.ai/speechtotext/v1/jobs/{job_id}/transcript",
        headers={"Authorization": f"Bearer {api_key}"}
    ).json()

    text = " ".join([e["value"] for m in transcript["monologues"] for e in m["elements"]])
    return text

@voice_to_text_router.post("/voice-to-text_test")
async def transform_voice_to_text(file: UploadFile = File(...) ):
    rev_api_key = os.getenv("rev_api_key")
    audio_bytes = await file.read()
    text = rev_transcribe_bytes(rev_api_key, audio_bytes)
    return {"text": text}

    

@voice_to_text_router.post("/question-asking")
async def transform_voice_to_text(file: UploadFile = File(...)):
    try:
        rev_api_key = os.getenv("rev_api_key")
        audio_bytes = await file.read()
        text = rev_transcribe_bytes(rev_api_key, audio_bytes)

        state = State(text=text, questions="")
        print("Initial state:", state)
        res = question_asker_agent.invoke(state)
        print("Result from question asker agent:", res)
        # return a proper dict
        return {
            "transcription_text": res.text,
            "questions": res.questions
        }
    except Exception as e:
        return {"error": str(e)}
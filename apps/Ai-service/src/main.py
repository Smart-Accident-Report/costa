from fastapi import FastAPI
from routes.ocr import ocr_router
from routes.voice_to_text import voice_to_text_router
app = FastAPI()
 
app.include_router(ocr_router)
app.include_router(voice_to_text_router)
@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI!"}


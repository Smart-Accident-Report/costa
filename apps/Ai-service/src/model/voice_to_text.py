from pydantic import BaseModel
from typing import Literal


class lang(BaseModel):
    lang: Literal["ar" , "en" , "fr"]

class voice_to_text_agent_state(BaseModel):
    translated_text :str
    additonal_qestions :str
    final_text :str


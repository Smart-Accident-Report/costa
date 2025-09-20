from langgraph.graph import StateGraph, END
from langchain_google_genai import ChatGoogleGenerativeAI
from dotenv import load_dotenv
import os
from pydantic import BaseModel

class State(BaseModel):
    text: str
    questions: str | None = None

load_dotenv()
genai_api_key = os.getenv("GENAI_API_KEY")  

model = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    api_key=genai_api_key,
    temperature=0
)

def ask_question(state: State) -> State:    
    print("GENAI_API_KEY:", genai_api_key)
    text = state.text
    print("Input text:", text)
    prompt = f"""
    Prompt for Insurance Accident Report Analysis Agent

You are an AI specialized in analyzing insurance accident reports. Your task is to:

Read the provided accident report carefully.

Identify missing, incomplete, or unclear information that is important for assessing the accident.

Ask clear, specific questions to gather the missing information.

Focus on the following key areas:

1. Vehicle Movement and Accident Circumstances

Direction and speed of your vehicle and the other(s) before impact.

Traffic signs/signals at the location (stop, yield, red light, etc.).

Lane positions and maneuvers (turning, overtaking, changing lanes, braking, etc.).

How the collision happened (point of impact, sequence of events).

2. Damages and Injuries

Visible vehicle damages (e.g., front bumper, left door).

Injuries to you, passengers, other parties, or pedestrians.

Other property damage (road signs, barriers, buildings).

3. Witnesses

Names and contact details of any independent witnesses.

4. Supporting Evidence

Sketch or diagram of the accident.

Photos/videos of vehicles, surroundings, and damages.

Police report number (if applicable).

5. Observations / Remarks

Other driver’s admission of fault (if any).

Suspected violations (speeding, phone use, running a red light).

Possible alcohol, drugs, or distractions.

Any unusual circumstances (mechanical failure, road hazard, sudden maneuver).

Instructions for the Agent:

Highlight any missing or unclear details.

Ask targeted questions to fill in gaps.

Keep questions concise and easy to answer.

Prioritize safety-related and legal details first.

Example of questions the agent might ask:

“What was the direction and speed of your vehicle and the other vehicle(s) just before impact?”

“Were there any traffic signs or signals at the accident location?”

“Can you provide a sketch or diagram showing how the collision occurred?”

“Were there any independent witnesses? Please provide their names and contact info.”

“What damages did each vehicle sustain, and were there any injuries?”

the rapport text {text}
"""
    
    res = model.invoke(prompt)
    print("Model response:", questions=res.content[0].text)
    return State(text=text, questions=res.content[0].text if hasattr(res, "content") else str(res))

# Create state graph
question_asker_agent = StateGraph(State)  
question_asker_agent.add_node("ask_question", ask_question)
question_asker_agent.set_entry_point("ask_question")
question_asker_agent.add_edge("ask_question", END)
question_asker_agent = question_asker_agent.compile()

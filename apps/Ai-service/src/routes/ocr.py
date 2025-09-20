from fastapi import APIRouter, File, UploadFile
from model.ocr import DrivingLicenceOCRResult , InsuranceOCROCRResult , CartGriseOCRResult
from dotenv import load_dotenv
import os 
from langchain_google_genai import ChatGoogleGenerativeAI 
import google.generativeai as genai
from fastapi.responses import JSONResponse
import json
import base64
from PIL import Image
import io
load_dotenv()
genai.configure(api_key=os.getenv("GENAI_API_KEY"))
model = genai.GenerativeModel("gemini-1.5-flash")

ocr_router = APIRouter(
    prefix="/ocr",  
    tags=["ocr"]    
)


@ocr_router.post("/test")
def test_endpoint():
    return {"message": "Test endpoint is working!"}


@ocr_router.post("/driving_licence")
async def driving_licence(file: UploadFile = File(...)):
    # Read and convert image to PIL Image
    img_bytes = await file.read()
    image = Image.open(io.BytesIO(img_bytes))
    
    # Prepare the prompt
    prompt = """Extract the following fields from the driving license image. If a field is not found, return null for that field:
    - license_id
    - first_name_ar
    - last_name_ar
    - first_name_en
    - last_name_en
    - nationl_card_id
    - birth_date
    - place_of_birth
    - expiration_date
    - creation_date
    - creation_place
    - license_type
    
    Return the result as a JSON object with these exact field names."""
    
    # Get response from model
    response = model.generate_content(
        contents=[prompt, image]
    )
    
    try:
        result_text = response.text
        json_start = result_text.find('{')
        json_end = result_text.rfind('}') + 1
        if json_start >= 0 and json_end > json_start:
            json_str = result_text[json_start:json_end]
            result_dict = json.loads(json_str)
        else:
            result_dict = {"error": "Could not parse JSON", "raw_response": result_text}
    except Exception as e:
        result_dict = {"error": str(e), "raw_response": result_text if 'result_text' in locals() else str(response)}

    # Validate & return
    return DrivingLicenceOCRResult(**result_dict)






@ocr_router.post("/cart_grise")
async def cart_grise(file: UploadFile = File(...)):
    # Read and convert image to PIL Image
    img_bytes = await file.read()
    image = Image.open(io.BytesIO(img_bytes))
    
    # Prepare the prompt
    prompt = """Extract the following fields from the driving license image. If a field is not found, return null for that field:
   
    Registration number (matricule / numéro d’immatriculation)
    First registration date (date de première mise en circulation)
    Vehicle type (voiture particulière, utilitaire, etc.)
    Brand and model (marque, modèle)
    Vehicle identification number (VIN / numéro de série)
    Engine number
    Fuel type (essence, diesel, GPL, etc.)
    Cylinder capacity (cylindrée)
    Fiscal horsepower (puissance fiscale)
    Number of seats
    
    Return the result as a JSON object with these exact field names."""
    
    # Get response from model
    response = model.generate_content(
        contents=[prompt, image]
    )
    
    try:
        result_text = response.text
        json_start = result_text.find('{')
        json_end = result_text.rfind('}') + 1
        if json_start >= 0 and json_end > json_start:
            json_str = result_text[json_start:json_end]
            result_dict = json.loads(json_str)
        else:
            result_dict = {"error": "Could not parse JSON", "raw_response": result_text}
    except Exception as e:
        result_dict = {"error": str(e), "raw_response": result_text if 'result_text' in locals() else str(response)}

    return CartGriseOCRResult(**result_dict)



@ocr_router.post("/insurance")
async def insurance(file: UploadFile = File(...)):
    # Read and convert image to PIL Image
    img_bytes = await file.read()
    image = Image.open(io.BytesIO(img_bytes))
    
    # Prepare the prompt
    prompt = """Extract the following fields from the driving license image. If a field is not found, return null for that field:
   
    Vehicle Information
    Registration number (numéro d’immatriculation / matricule)
    Brand and mode
    Chassis number (VIN)

    🔹 Owner Information
    Full name of the insured person
    Addres

    🔹 Insurance Information
    Insurance company name
    Policy number
    Type of coverage (responsabilité civile, tous risques, etc.)
    Start date & end date of coverage
    Premium amount (sometimes mentioned)
        
    Return the result as a JSON object with these exact field names."""
    
    # Get response from model
    response = model.generate_content(
        contents=[prompt, image]
    )
    
    try:
        # Extract JSON from the response
        result_text = response.text
        # Find the JSON part (assuming it's within the text)
        json_start = result_text.find('{')
        json_end = result_text.rfind('}') + 1
        if json_start >= 0 and json_end > json_start:
            json_str = result_text[json_start:json_end]
            result = json.loads(json_str)
        else:
            result = {
                "error": "Could not parse JSON from response",
                "raw_response": result_text
            }
    except Exception as e:
        result = {
            "error": str(e),
            "raw_response": result_text if 'result_text' in locals() else str(response)
        }

    return InsuranceOCROCRResult(content=result)
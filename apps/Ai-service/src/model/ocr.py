from pydantic import BaseModel


class DrivingLicenceOCRResult(BaseModel):
    license_id: str | None
    first_name_ar: str | None
    last_name_ar: str | None
    first_name_en: str | None
    last_name_en: str | None
    nationl_card_id: str | None
    birth_date: str | None
    place_of_birth: str | None
    expiration_date: str | None
    creation_date: str | None
    creation_place: str | None
    license_type: str | None    



class CartGriseOCRResult(BaseModel):
    registration_number: str | None
    owner_name: str | None
    owner_address: str | None
    vehicle_make: str | None
    vehicle_model: str | None
    vehicle_color: str | None
    vehicle_type: str | None
    engine_number: str | None
    chassis_number: str | None
    fuel_type: str | None
    power: str | None
    weight: str | None
    seats: str | None
    registration_date: str | None

from pydantic import BaseModel
from typing import Optional

class InsuranceOCROCRResult(BaseModel):
    # Vehicle Information
    registration_number: Optional[str] = None   # numéro d’immatriculation / matricule
    brand_and_model: Optional[str] = None
    chassis_number: Optional[str] = None        # VIN

    # Owner Information
    owner_full_name: Optional[str] = None
    owner_address: Optional[str] = None

    # Insurance Information
    insurance_company_name: Optional[str] = None
    policy_number: Optional[str] = None
    coverage_type: Optional[str] = None         # responsabilité civile, tous risques, etc.
    coverage_start_date: Optional[str] = None
    coverage_end_date: Optional[str] = None
    premium_amount: Optional[str] = None

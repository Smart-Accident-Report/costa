package insurance

import (
	validation "github.com/go-ozzo/ozzo-validation/v4"
	"time"
)

type CreateInsuranceRequest struct {
	VehicleID     uint      `json:"vehicle_id"`
	Assuree       bool      `json:"assuree"`
	AssureNom     string    `json:"assure_nom"`
	AssurePrenom  string    `json:"assure_prenom"`
	AssureAdresse string    `json:"assure_adresse"`
	Company       string    `json:"company"`
	PolicyNumber  string    `json:"policy_number"`
	ValidFrom     time.Time `json:"valid_from"`
	ValidTo       time.Time `json:"valid_to"`
	AgencyCode    string    `json:"agency_code"`
	CoverageType  string    `json:"coverage_type"`
	AssurancePath string    `json:"assurance_path"`
}

func (r CreateInsuranceRequest) Validate() error {
	return validation.ValidateStruct(&r,
		validation.Field(&r.VehicleID, validation.Required),
		validation.Field(&r.AssureNom, validation.Required, validation.Length(2, 50)),
		validation.Field(&r.AssurePrenom, validation.Required, validation.Length(2, 50)),
		validation.Field(&r.AssureAdresse, validation.Required, validation.Length(5, 200)),
		validation.Field(&r.Company, validation.Required, validation.Length(2, 100)),
		validation.Field(&r.PolicyNumber, validation.Required, validation.Length(2, 50)),
		validation.Field(&r.ValidFrom, validation.Required),
		validation.Field(&r.ValidTo, validation.Required),
		validation.Field(&r.AgencyCode, validation.Required, validation.Length(4, 10)),
	)
}

type UpdateInsuranceRequest struct {
	ID uint `json:"id"`
	CreateInsuranceRequest
}

func (r UpdateInsuranceRequest) Validate() error {
	if r.ID == 0 {
		return validation.NewError("validation_insurance", "invalid insurance ID")
	}
	return r.CreateInsuranceRequest.Validate()
}

type GetInsuranceRequest struct { ID uint `json:"id"` }
func (r GetInsuranceRequest) Validate() error { if r.ID==0 {return validation.NewError("validation_insurance","invalid insurance ID")}; return nil }

type DeleteInsuranceRequest struct { ID uint `json:"id"` }
func (r DeleteInsuranceRequest) Validate() error { if r.ID==0 {return validation.NewError("validation_insurance","invalid insurance ID")}; return nil }

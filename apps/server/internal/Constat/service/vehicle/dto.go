package vehicle

import (
	validation "github.com/go-ozzo/ozzo-validation/v4"
)

type CreateVehicleRequest struct {
	OwnerID       uint    `json:"owner_id"`
	Brand         string  `json:"brand"`
	Model         string  `json:"model"`
	Year          int     `json:"year"`
	EnginePower   string  `json:"engine_power"`
	Seats         int     `json:"seats"`
	ChassisNumber string  `json:"chassis_number"`
	LicensePlate  string  `json:"license_plate"`
	Energy        string  `json:"energy"`
	VehicleType   string  `json:"vehicle_type"`
	Wilaya        int     `json:"wilaya"`
	ValeurVenale  float64 `json:"valeur_venale"`
	PaiementCCP   bool    `json:"paiement_ccp"`
	Moins25Ans    bool    `json:"moins_25_ans"`
	PermisPlus1An bool    `json:"permis_plus_1an"`
	CarteGrisePath string `json:"carte_grise_path"`
}

func (r CreateVehicleRequest) Validate() error {
	return validation.ValidateStruct(&r,
		validation.Field(&r.OwnerID, validation.Required),
		validation.Field(&r.Brand, validation.Required, validation.Length(2, 50)),
		validation.Field(&r.Model, validation.Required, validation.Length(1, 50)),
		validation.Field(&r.Year, validation.Required, validation.Min(1900), validation.Max(2100)),
		validation.Field(&r.EnginePower, validation.Required),
		validation.Field(&r.Seats, validation.Required, validation.Min(1), validation.Max(20)),
		validation.Field(&r.ChassisNumber, validation.Required, validation.Length(3, 50)),
		validation.Field(&r.LicensePlate, validation.Required, validation.Length(3, 20)),
	)
}

type UpdateVehicleRequest struct {
	ID uint `json:"id"`
	CreateVehicleRequest
}

func (r UpdateVehicleRequest) Validate() error {
	if r.ID == 0 {
		return validation.NewError("validation_vehicle", "invalid vehicle ID")
	}
	return r.CreateVehicleRequest.Validate()
}

type GetVehicleRequest struct { ID uint `json:"id"` }
func (r GetVehicleRequest) Validate() error { if r.ID==0 {return validation.NewError("validation_vehicle","invalid vehicle ID")}; return nil }

type DeleteVehicleRequest struct { ID uint `json:"id"` }
func (r DeleteVehicleRequest) Validate() error { if r.ID==0 {return validation.NewError("validation_vehicle","invalid vehicle ID")}; return nil }

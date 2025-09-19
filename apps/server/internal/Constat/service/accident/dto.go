package accident

import (
	validation "github.com/go-ozzo/ozzo-validation/v4"
	"time"
)

type CreateAccidentRequest struct {
	DateTime         time.Time `json:"date_time"`
	Location         string    `json:"location"`
	Circonstances    string    `json:"circonstances"`

	VehicleAID       uint   `json:"vehicle_a_id"`
	DriverAID        uint   `json:"driver_a_id"`
	PointDeChocA     string `json:"point_de_choc_a"`
	DegatsApparentsA string `json:"degats_apparents_a"`
	ObservationsA    string `json:"observations_a"`
	PVPoliceA        string `json:"pv_police_a"`
	PVGendarmerieA   string `json:"pv_gendarmerie_a"`

	VehicleBID       uint   `json:"vehicle_b_id"`
	DriverBID        uint   `json:"driver_b_id"`
	PointDeChocB     string `json:"point_de_choc_b"`
	DegatsApparentsB string `json:"degats_apparents_b"`
	ObservationsB    string `json:"observations_b"`
	PVPoliceB        string `json:"pv_police_b"`
	PVGendarmerieB   string `json:"pv_gendarmerie_b"`

	Status string `json:"status"`
}

func (r CreateAccidentRequest) Validate() error {
	return validation.ValidateStruct(&r,
		validation.Field(&r.DateTime, validation.Required),
		validation.Field(&r.Location, validation.Required, validation.Length(3, 200)),
		validation.Field(&r.VehicleAID, validation.Required),
		validation.Field(&r.DriverAID, validation.Required),
	)
}

type UpdateAccidentRequest struct {
	ID uint `json:"id"`
	CreateAccidentRequest
}

func (r UpdateAccidentRequest) Validate() error {
	if r.ID == 0 {
		return validation.NewError("validation_accident", "invalid accident ID")
	}
	return r.CreateAccidentRequest.Validate()
}

type GetAccidentRequest struct { ID uint `json:"id"` }
func (r GetAccidentRequest) Validate() error { if r.ID==0 {return validation.NewError("validation_accident","invalid accident ID")}; return nil }

type DeleteAccidentRequest struct { ID uint `json:"id"` }
func (r DeleteAccidentRequest) Validate() error { if r.ID==0 {return validation.NewError("validation_accident","invalid accident ID")}; return nil }

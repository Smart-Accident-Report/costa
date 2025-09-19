package service

import (
	validation "github.com/go-ozzo/ozzo-validation/v4"
)

type RegisterRequest struct {
	Username          string `json:"username"`
	Password          string `json:"password"`
	VehicleIDNumber   string `json:"vehicle_id_number"`
	YearOfCirculation int    `json:"year_of_circulation"`
	WilayaNumber      int    `json:"wilaya_number"`
	OwnerName         string `json:"owner_name"`
	OwnerAddress      string `json:"owner_address"`
	ChipSerial        string `json:"chip_serial"`
}

func (r RegisterRequest) Validate() error {
	return validation.ValidateStruct(&r,
		validation.Field(&r.Username, validation.Required, validation.Length(3, 50)),
		validation.Field(&r.Password, validation.Required, validation.Length(6, 100)),
		validation.Field(&r.VehicleIDNumber, validation.Required, validation.Length(3, 20)),
		validation.Field(&r.YearOfCirculation, validation.Required, validation.Min(1900), validation.Max(2100)),
		validation.Field(&r.WilayaNumber, validation.Required, validation.Min(1), validation.Max(58)),
		validation.Field(&r.OwnerName, validation.Required, validation.Length(3, 100)),
		validation.Field(&r.OwnerAddress, validation.Required, validation.Length(3, 200)),
		validation.Field(&r.ChipSerial, validation.Required, validation.Length(3, 50)),
	)
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func (r LoginRequest) Validate() error {
	return validation.ValidateStruct(&r,
		validation.Field(&r.Username, validation.Required),
		validation.Field(&r.Password, validation.Required),
	)
}

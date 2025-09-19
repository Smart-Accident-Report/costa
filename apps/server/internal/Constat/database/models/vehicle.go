package models

import (
	"gorm.io/gorm"
)


type Vehicle struct {
    gorm.Model
    OwnerID        uint
    Brand          string
    ModelName      string
    Year           int
    EnginePower    string
    Seats          int
    ChassisNumber  string `gorm:"unique"`
    LicensePlate   string `gorm:"unique"`
    Energy         string
    VehicleType    string // provisoire / permanent
    Wilaya         int
    ValeurVenale   float64

    // Payment info
    PaiementCCP     bool
    Moins25Ans      bool
    PermisPlus1An   bool

    // Scanned documents
    CarteGrisePath  string

    Insurances      []Insurance
}

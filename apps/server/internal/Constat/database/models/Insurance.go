package models

import (
	"time"

	"gorm.io/gorm"
)


type Insurance struct {
    gorm.Model
    VehicleID       uint
    Assuree         bool
    AssureNom       string
    AssurePrenom    string
    AssureAdresse   string
    Company         string
    PolicyNumber    string
    ValidFrom       time.Time
    ValidTo         time.Time
    AgencyCode      string // 4 digits
    CoverageType    string // Tout risque, tiers, etc.
    AssurancePath   string // scanned insurance document
}

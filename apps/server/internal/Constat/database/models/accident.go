package models

import (
	"time"

	"gorm.io/gorm"
)

type Accident struct {
    gorm.Model
    DateTime         time.Time
    Location         string
    Circonstances    string // description / sketch
    
    // Vehicle A (assuree)
    VehicleAID       uint
    DriverAID        uint
    PointDeChocA     string
    DegatsApparentsA string
    ObservationsA    string
    PVPoliceA        string
    PVGendarmerieA   string

    // Vehicle B
    VehicleBID       uint
    DriverBID        uint
    PointDeChocB     string
    DegatsApparentsB string
    ObservationsB    string
    PVPoliceB        string
    PVGendarmerieB   string

    Status           string 
}

package models

import (
    "gorm.io/gorm"
)

type User struct {
    gorm.Model
    Username          string         `gorm:"unique;not null"`
    Password          string         `gorm:"not null"`
    VehicleIDNumber   string
    YearOfCirculation int
    WilayaNumber      int
    OwnerName         string
    OwnerAddress      string
    ChipSerial        string
}
package vehicle

import (
	"errors"

	"github.com/Smart-Accident-Report/costa/internal/Constat/database/models"
	"gorm.io/gorm"
)

type VehicleService struct { db *gorm.DB }

func NewVehicleService(db *gorm.DB) *VehicleService { return &VehicleService{db: db} }

func (s *VehicleService) CreateVehicle(req CreateVehicleRequest) (*models.Vehicle, error) {
	if err := req.Validate(); err != nil { return nil, err }
	vehicle := &models.Vehicle{
		OwnerID: req.OwnerID, Brand: req.Brand, ModelName: req.Model, Year: req.Year,
		EnginePower: req.EnginePower, Seats: req.Seats, ChassisNumber: req.ChassisNumber,
		LicensePlate: req.LicensePlate, Energy: req.Energy, VehicleType: req.VehicleType,
		Wilaya: req.Wilaya, ValeurVenale: req.ValeurVenale, PaiementCCP: req.PaiementCCP,
		Moins25Ans: req.Moins25Ans, PermisPlus1An: req.PermisPlus1An, CarteGrisePath: req.CarteGrisePath,
	}
	if err := s.db.Create(vehicle).Error; err != nil { return nil, err }
	return vehicle, nil
}

func (s *VehicleService) GetVehicle(req GetVehicleRequest) (*models.Vehicle, error) {
	if err := req.Validate(); err != nil { return nil, err }
	var vehicle models.Vehicle
	if err := s.db.First(&vehicle, req.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) { return nil, errors.New("vehicle not found") }
		return nil, err
	}
	return &vehicle, nil
}

func (s *VehicleService) UpdateVehicle(req UpdateVehicleRequest) (*models.Vehicle, error) {
	if err := req.Validate(); err != nil { return nil, err }
	var vehicle models.Vehicle
	if err := s.db.First(&vehicle, req.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) { return nil, errors.New("vehicle not found") }
		return nil, err
	}
	vehicle.Brand = req.Brand
	vehicle.ModelName = req.Model
	vehicle.Year = req.Year
	vehicle.EnginePower = req.EnginePower
	vehicle.Seats = req.Seats
	vehicle.ChassisNumber = req.ChassisNumber
	vehicle.LicensePlate = req.LicensePlate
	vehicle.Energy = req.Energy
	vehicle.VehicleType = req.VehicleType
	vehicle.Wilaya = req.Wilaya
	vehicle.ValeurVenale = req.ValeurVenale
	vehicle.PaiementCCP = req.PaiementCCP
	vehicle.Moins25Ans = req.Moins25Ans
	vehicle.PermisPlus1An = req.PermisPlus1An
	vehicle.CarteGrisePath = req.CarteGrisePath
	if err := s.db.Save(&vehicle).Error; err != nil { return nil, err }
	return &vehicle, nil
}

func (s *VehicleService) DeleteVehicle(req DeleteVehicleRequest) error {
	if err := req.Validate(); err != nil { return err }
	if err := s.db.Delete(&models.Vehicle{}, req.ID).Error; err != nil { return err }
	return nil
}

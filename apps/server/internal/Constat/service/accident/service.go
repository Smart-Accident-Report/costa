package accident

import (
	"errors"

	"github.com/Smart-Accident-Report/costa/internal/Constat/database/models"
	"gorm.io/gorm"
)

type AccidentService struct { db *gorm.DB }

func NewAccidentService(db *gorm.DB) *AccidentService { return &AccidentService{db: db} }

func (s *AccidentService) CreateAccident(req CreateAccidentRequest) (*models.Accident, error) {
	if err := req.Validate(); err != nil { return nil, err }
	acc := &models.Accident{
		DateTime: req.DateTime,
		Location: req.Location,
		Circonstances: req.Circonstances,
		VehicleAID: req.VehicleAID,
		DriverAID: req.DriverAID,
		PointDeChocA: req.PointDeChocA,
		DegatsApparentsA: req.DegatsApparentsA,
		ObservationsA: req.ObservationsA,
		PVPoliceA: req.PVPoliceA,
		PVGendarmerieA: req.PVGendarmerieA,
		VehicleBID: req.VehicleBID,
		DriverBID: req.DriverBID,
		PointDeChocB: req.PointDeChocB,
		DegatsApparentsB: req.DegatsApparentsB,
		ObservationsB: req.ObservationsB,
		PVPoliceB: req.PVPoliceB,
		PVGendarmerieB: req.PVGendarmerieB,
		Status: req.Status,
	}
	if err := s.db.Create(acc).Error; err != nil { return nil, err }
	return acc, nil
}

func (s *AccidentService) GetAccident(req GetAccidentRequest) (*models.Accident, error) {
	if err := req.Validate(); err != nil { return nil, err }
	var acc models.Accident
	if err := s.db.First(&acc, req.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) { return nil, errors.New("accident not found") }
		return nil, err
	}
	return &acc, nil
}

func (s *AccidentService) UpdateAccident(req UpdateAccidentRequest) (*models.Accident, error) {
	if err := req.Validate(); err != nil { return nil, err }
	var acc models.Accident
	if err := s.db.First(&acc, req.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) { return nil, errors.New("accident not found") }
		return nil, err
	}
	acc.DateTime = req.DateTime
	acc.Location = req.Location
	acc.Circonstances = req.Circonstances
	acc.VehicleAID = req.VehicleAID
	acc.DriverAID = req.DriverAID
	acc.PointDeChocA = req.PointDeChocA
	acc.DegatsApparentsA = req.DegatsApparentsA
	acc.ObservationsA = req.ObservationsA
	acc.PVPoliceA = req.PVPoliceA
	acc.PVGendarmerieA = req.PVGendarmerieA
	acc.VehicleBID = req.VehicleBID
	acc.DriverBID = req.DriverBID
	acc.PointDeChocB = req.PointDeChocB
	acc.DegatsApparentsB = req.DegatsApparentsB
	acc.ObservationsB = req.ObservationsB
	acc.PVPoliceB = req.PVPoliceB
	acc.PVGendarmerieB = req.PVGendarmerieB
	acc.Status = req.Status

	if err := s.db.Save(&acc).Error; err != nil { return nil, err }
	return &acc, nil
}

func (s *AccidentService) DeleteAccident(req DeleteAccidentRequest) error {
	if err := req.Validate(); err != nil { return err }
	if err := s.db.Delete(&models.Accident{}, req.ID).Error; err != nil { return err }
	return nil
}

package insurance

import (
	"errors"

	"github.com/Smart-Accident-Report/costa/internal/Constat/database/models"
	"gorm.io/gorm"
)

type InsuranceService struct { db *gorm.DB }

func NewInsuranceService(db *gorm.DB) *InsuranceService { return &InsuranceService{db: db} }

func (s *InsuranceService) CreateInsurance(req CreateInsuranceRequest) (*models.Insurance, error) {
	if err := req.Validate(); err != nil { return nil, err }
	ins := &models.Insurance{
		VehicleID: req.VehicleID,
		Assuree: req.Assuree,
		AssureNom: req.AssureNom,
		AssurePrenom: req.AssurePrenom,
		AssureAdresse: req.AssureAdresse,
		Company: req.Company,
		PolicyNumber: req.PolicyNumber,
		ValidFrom: req.ValidFrom,
		ValidTo: req.ValidTo,
		AgencyCode: req.AgencyCode,
		CoverageType: req.CoverageType,
		AssurancePath: req.AssurancePath,
	}
	if err := s.db.Create(ins).Error; err != nil { return nil, err }
	return ins, nil
}

func (s *InsuranceService) GetInsurance(req GetInsuranceRequest) (*models.Insurance, error) {
	if err := req.Validate(); err != nil { return nil, err }
	var ins models.Insurance
	if err := s.db.First(&ins, req.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) { return nil, errors.New("insurance not found") }
		return nil, err
	}
	return &ins, nil
}

func (s *InsuranceService) UpdateInsurance(req UpdateInsuranceRequest) (*models.Insurance, error) {
	if err := req.Validate(); err != nil { return nil, err }
	var ins models.Insurance
	if err := s.db.First(&ins, req.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) { return nil, errors.New("insurance not found") }
		return nil, err
	}
	ins.VehicleID = req.VehicleID
	ins.Assuree = req.Assuree
	ins.AssureNom = req.AssureNom
	ins.AssurePrenom = req.AssurePrenom
	ins.AssureAdresse = req.AssureAdresse
	ins.Company = req.Company
	ins.PolicyNumber = req.PolicyNumber
	ins.ValidFrom = req.ValidFrom
	ins.ValidTo = req.ValidTo
	ins.AgencyCode = req.AgencyCode
	ins.CoverageType = req.CoverageType
	ins.AssurancePath = req.AssurancePath

	if err := s.db.Save(&ins).Error; err != nil { return nil, err }
	return &ins, nil
}

func (s *InsuranceService) DeleteInsurance(req DeleteInsuranceRequest) error {
	if err := req.Validate(); err != nil { return err }
	if err := s.db.Delete(&models.Insurance{}, req.ID).Error; err != nil { return err }
	return nil
}

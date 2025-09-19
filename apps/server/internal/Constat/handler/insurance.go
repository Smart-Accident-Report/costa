package handler

import (
	"context"
	"time"

	"github.com/Smart-Accident-Report/costa/internal/Constat/service/insurance"
	pb "github.com/Smart-Accident-Report/costa/rpc/insurance"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type TwirpInsuranceHandler struct {
	srv *insurance.InsuranceService
}

func NewTwirpInsuranceHandler(s *insurance.InsuranceService) *TwirpInsuranceHandler {
	return &TwirpInsuranceHandler{srv: s}
}

// pbTimestamp converts time.Time to protobuf timestamp
func pbTimestamp(t time.Time) *timestamppb.Timestamp {
	return timestamppb.New(t)
}

// CreateInsurance
func (h *TwirpInsuranceHandler) CreateInsurance(ctx context.Context, req *pb.CreateInsuranceRequest) (*pb.CreateInsuranceResponse, error) {
	r := insurance.CreateInsuranceRequest{
		VehicleID:     uint(req.VehicleId),
		Assuree:       req.Assuree,
		AssureNom:     req.AssureNom,
		AssurePrenom:  req.AssurePrenom,
		AssureAdresse: req.AssureAdresse,
		Company:       req.Company,
		PolicyNumber:  req.PolicyNumber,
		ValidFrom:     req.ValidFrom.AsTime(),
		ValidTo:       req.ValidTo.AsTime(),
		AgencyCode:    req.AgencyCode,
		CoverageType:  req.CoverageType,
		AssurancePath: req.AssurancePath,
	}

	ins, err := h.srv.CreateInsurance(r)
	if err != nil {
		return nil, err
	}

	return &pb.CreateInsuranceResponse{
		Id:            int64(ins.ID),
		VehicleId:     int64(ins.VehicleID),
		Assuree:       ins.Assuree,
		AssureNom:     ins.AssureNom,
		AssurePrenom:  ins.AssurePrenom,
		AssureAdresse: ins.AssureAdresse,
		Company:       ins.Company,
		PolicyNumber:  ins.PolicyNumber,
		ValidFrom:     pbTimestamp(ins.ValidFrom),
		ValidTo:       pbTimestamp(ins.ValidTo),
		AgencyCode:    ins.AgencyCode,
		CoverageType:  ins.CoverageType,
		AssurancePath: ins.AssurancePath,
	}, nil
}

// GetInsurance
func (h *TwirpInsuranceHandler) GetInsurance(ctx context.Context, req *pb.GetInsuranceRequest) (*pb.GetInsuranceResponse, error) {
	r := insurance.GetInsuranceRequest{ID: uint(req.Id)}
	ins, err := h.srv.GetInsurance(r)
	if err != nil {
		return nil, err
	}

	return &pb.GetInsuranceResponse{
		Id:            int64(ins.ID),
		VehicleId:     int64(ins.VehicleID),
		Assuree:       ins.Assuree,
		AssureNom:     ins.AssureNom,
		AssurePrenom:  ins.AssurePrenom,
		AssureAdresse: ins.AssureAdresse,
		Company:       ins.Company,
		PolicyNumber:  ins.PolicyNumber,
		ValidFrom:     pbTimestamp(ins.ValidFrom),
		ValidTo:       pbTimestamp(ins.ValidTo),
		AgencyCode:    ins.AgencyCode,
		CoverageType:  ins.CoverageType,
		AssurancePath: ins.AssurancePath,
	}, nil
}

// UpdateInsurance
func (h *TwirpInsuranceHandler) UpdateInsurance(ctx context.Context, req *pb.UpdateInsuranceRequest) (*pb.UpdateInsuranceResponse, error) {
	r := insurance.UpdateInsuranceRequest{
		ID: uint(req.Id),
		CreateInsuranceRequest: insurance.CreateInsuranceRequest{
			VehicleID:     uint(req.VehicleId),
			Assuree:       req.Assuree,
			AssureNom:     req.AssureNom,
			AssurePrenom:  req.AssurePrenom,
			AssureAdresse: req.AssureAdresse,
			Company:       req.Company,
			PolicyNumber:  req.PolicyNumber,
			ValidFrom:     req.ValidFrom.AsTime(),
			ValidTo:       req.ValidTo.AsTime(),
			AgencyCode:    req.AgencyCode,
			CoverageType:  req.CoverageType,
			AssurancePath: req.AssurancePath,
		},
	}

	ins, err := h.srv.UpdateInsurance(r)
	if err != nil {
		return nil, err
	}

	return &pb.UpdateInsuranceResponse{
		Id:            int64(ins.ID),
		VehicleId:     int64(ins.VehicleID),
		Assuree:       ins.Assuree,
		AssureNom:     ins.AssureNom,
		AssurePrenom:  ins.AssurePrenom,
		AssureAdresse: ins.AssureAdresse,
		Company:       ins.Company,
		PolicyNumber:  ins.PolicyNumber,
		ValidFrom:     pbTimestamp(ins.ValidFrom),
		ValidTo:       pbTimestamp(ins.ValidTo),
		AgencyCode:    ins.AgencyCode,
		CoverageType:  ins.CoverageType,
		AssurancePath: ins.AssurancePath,
	}, nil
}

// DeleteInsurance
func (h *TwirpInsuranceHandler) DeleteInsurance(ctx context.Context, req *pb.DeleteInsuranceRequest) (*pb.DeleteInsuranceResponse, error) {
	r := insurance.DeleteInsuranceRequest{ID: uint(req.Id)}
	if err := h.srv.DeleteInsurance(r); err != nil {
		return nil, err
	}
	return &pb.DeleteInsuranceResponse{}, nil
}

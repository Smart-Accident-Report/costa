package handler

import (
	"context"

	"github.com/Smart-Accident-Report/costa/internal/Constat/service/vehicle"
	pb "github.com/Smart-Accident-Report/costa/rpc/vehicle"
)

type TwirpVehicleHandler struct {
	srv *vehicle.VehicleService
}

func NewTwirpVehicleHandler(s *vehicle.VehicleService) *TwirpVehicleHandler {
	return &TwirpVehicleHandler{srv: s}
}

// CreateVehicle
func (h *TwirpVehicleHandler) CreateVehicle(ctx context.Context, req *pb.CreateVehicleRequest) (*pb.CreateVehicleResponse, error) {
	r := vehicle.CreateVehicleRequest{
		OwnerID:        uint(req.OwnerId),
		Brand:          req.Brand,
		Model:          req.Model,
		Year:           int(req.Year),
		EnginePower:    req.EnginePower,
		Seats:          int(req.Seats),
		ChassisNumber:  req.ChassisNumber,
		LicensePlate:   req.LicensePlate,
		Energy:         req.Energy,
		VehicleType:    req.VehicleType,
		Wilaya:         int(req.Wilaya),
		ValeurVenale:   req.ValeurVenale,
		PaiementCCP:    req.PaiementCcp,
		Moins25Ans:     req.Moins25Ans,
		PermisPlus1An:  req.PermisPlus1An,
		CarteGrisePath: req.CarteGrisePath,
	}

	v, err := h.srv.CreateVehicle(r)
	if err != nil {
		return nil, err
	}

	return &pb.CreateVehicleResponse{
		Id:             int64(v.ID),
		OwnerId:        int64(v.OwnerID),
		Brand:          v.Brand,
		Model:          v.ModelName,
		Year:           int32(v.Year),
		EnginePower:    v.EnginePower,
		Seats:          int32(v.Seats),
		ChassisNumber:  v.ChassisNumber,
		LicensePlate:   v.LicensePlate,
		Energy:         v.Energy,
		VehicleType:    v.VehicleType,
		Wilaya:         int32(v.Wilaya),
		ValeurVenale:   v.ValeurVenale,
		PaiementCcp:    v.PaiementCCP,
		Moins_25Ans:    v.Moins25Ans,
		PermisPlus_1An: v.PermisPlus1An,
		CarteGrisePath: v.CarteGrisePath,
	}, nil
}

// GetVehicle
func (h *TwirpVehicleHandler) GetVehicle(ctx context.Context, req *pb.GetVehicleRequest) (*pb.GetVehicleResponse, error) {
	r := vehicle.GetVehicleRequest{ID: uint(req.Id)}
	v, err := h.srv.GetVehicle(r)
	if err != nil {
		return nil, err
	}

	return &pb.GetVehicleResponse{
		Id:             int64(v.ID),
		OwnerId:        int64(v.OwnerID),
		Brand:          v.Brand,
		Model:          v.ModelName,
		Year:           int32(v.Year),
		EnginePower:    v.EnginePower,
		Seats:          int32(v.Seats),
		ChassisNumber:  v.ChassisNumber,
		LicensePlate:   v.LicensePlate,
		Energy:         v.Energy,
		VehicleType:    v.VehicleType,
		Wilaya:         int32(v.Wilaya),
		ValeurVenale:   v.ValeurVenale,
		PaiementCcp:    v.PaiementCCP,
		Moins_25Ans:    v.Moins25Ans,
		PermisPlus_1An: v.PermisPlus1An,
		CarteGrisePath: v.CarteGrisePath,
	}, nil
}

// UpdateVehicle
func (h *TwirpVehicleHandler) UpdateVehicle(ctx context.Context, req *pb.UpdateVehicleRequest) (*pb.UpdateVehicleResponse, error) {
	r := vehicle.UpdateVehicleRequest{
		ID: uint(req.Id),
		CreateVehicleRequest: vehicle.CreateVehicleRequest{
			OwnerID:        uint(req.OwnerId),
			Brand:          req.Brand,
			Model:          req.Model,
			Year:           int(req.Year),
			EnginePower:    req.EnginePower,
			Seats:          int(req.Seats),
			ChassisNumber:  req.ChassisNumber,
			LicensePlate:   req.LicensePlate,
			Energy:         req.Energy,
			VehicleType:    req.VehicleType,
			Wilaya:         int(req.Wilaya),
			ValeurVenale:   req.ValeurVenale,
			PaiementCCP:    req.PaiementCcp,
			Moins25Ans:     req.Moins_25Ans,
			PermisPlus1An:  req.PermisPlus_1An,
			CarteGrisePath: req.CarteGrisePath,
		},
	}

	v, err := h.srv.UpdateVehicle(r)
	if err != nil {
		return nil, err
	}

	return &pb.UpdateVehicleResponse{
		Id:             int64(v.ID),
		OwnerId:        int64(v.OwnerID),
		Brand:          v.Brand,
		Model:          v.ModelName,
		Year:           int32(v.Year),
		EnginePower:    v.EnginePower,
		Seats:          int32(v.Seats),
		ChassisNumber:  v.ChassisNumber,
		LicensePlate:   v.LicensePlate,
		Energy:         v.Energy,
		VehicleType:    v.VehicleType,
		Wilaya:         int32(v.Wilaya),
		ValeurVenale:   v.ValeurVenale,
		PaiementCcp:    v.PaiementCCP,
		Moins_25Ans:    v.Moins25Ans,
		PermisPlus_1An: v.PermisPlus1An,
		CarteGrisePath: v.CarteGrisePath,
	}, nil
}

// DeleteVehicle
func (h *TwirpVehicleHandler) DeleteVehicle(ctx context.Context, req *pb.DeleteVehicleRequest) (*pb.DeleteVehicleResponse, error) {
	r := vehicle.DeleteVehicleRequest{ID: uint(req.Id)}
	if err := h.srv.DeleteVehicle(r); err != nil {
		return nil, err
	}
	return &pb.DeleteVehicleResponse{}, nil
}

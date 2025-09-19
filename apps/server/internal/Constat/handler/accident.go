package handler

import (
	"context"
	"time"

	"github.com/Smart-Accident-Report/costa/internal/Constat/service/accident"
	pb "github.com/Smart-Accident-Report/costa/rpc/accident"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type TwirpAccidentHandler struct {
	srv *accident.AccidentService
}

func NewTwirpAccidentHandler(s *accident.AccidentService) *TwirpAccidentHandler {
	return &TwirpAccidentHandler{srv: s}
}

// pbTimestamp converts time.Time to protobuf timestamp
func pbAccidentTimestamp(t time.Time) *timestamppb.Timestamp {
	return timestamppb.New(t)
}

// CreateAccident
func (h *TwirpAccidentHandler) CreateAccident(ctx context.Context, req *pb.CreateAccidentRequest) (*pb.CreateAccidentResponse, error) {
	r := accident.CreateAccidentRequest{
		DateTime:         req.DateTime.AsTime(),
		Location:         req.Location,
		Circonstances:    req.Circonstances,
		VehicleAID:       uint(req.VehicleAId),
		DriverAID:        uint(req.DriverAId),
		PointDeChocA:     req.PointDeChocA,
		DegatsApparentsA: req.DegatsApparentsA,
		ObservationsA:    req.ObservationsA,
		PVPoliceA:        req.PvPoliceA,
		PVGendarmerieA:   req.PvGendarmerieA,
		VehicleBID:       uint(req.VehicleBId),
		DriverBID:        uint(req.DriverBId),
		PointDeChocB:     req.PointDeChocB,
		DegatsApparentsB: req.DegatsApparentsB,
		ObservationsB:    req.ObservationsB,
		PVPoliceB:        req.PvPoliceB,
		PVGendarmerieB:   req.PvGendarmerieB,
		Status:           req.Status,
	}

	acc, err := h.srv.CreateAccident(r)
	if err != nil {
		return nil, err
	}

	return &pb.CreateAccidentResponse{
		Id:               int64(acc.ID),
		DateTime:         pbAccidentTimestamp(acc.DateTime),
		Location:         acc.Location,
		Circonstances:    acc.Circonstances,
		VehicleAId:       int64(acc.VehicleAID),
		DriverAId:        int64(acc.DriverAID),
		PointDeChocA:     acc.PointDeChocA,
		DegatsApparentsA: acc.DegatsApparentsA,
		ObservationsA:    acc.ObservationsA,
		PvPoliceA:        acc.PVPoliceA,
		PvGendarmerieA:   acc.PVGendarmerieA,
		VehicleBId:       int64(acc.VehicleBID),
		DriverBId:        int64(acc.DriverBID),
		PointDeChocB:     acc.PointDeChocB,
		DegatsApparentsB: acc.DegatsApparentsB,
		ObservationsB:    acc.ObservationsB,
		PvPoliceB:        acc.PVPoliceB,
		PvGendarmerieB:   acc.PVGendarmerieB,
		Status:           acc.Status,
	}, nil
}

// GetAccident
func (h *TwirpAccidentHandler) GetAccident(ctx context.Context, req *pb.GetAccidentRequest) (*pb.GetAccidentResponse, error) {
	r := accident.GetAccidentRequest{ID: uint(req.Id)}
	acc, err := h.srv.GetAccident(r)
	if err != nil {
		return nil, err
	}

	return &pb.GetAccidentResponse{
		Id:               int64(acc.ID),
		DateTime:         pbAccidentTimestamp(acc.DateTime),
		Location:         acc.Location,
		Circonstances:    acc.Circonstances,
		VehicleAId:       int64(acc.VehicleAID),
		DriverAId:        int64(acc.DriverAID),
		PointDeChocA:     acc.PointDeChocA,
		DegatsApparentsA: acc.DegatsApparentsA,
		ObservationsA:    acc.ObservationsA,
		PvPoliceA:        acc.PVPoliceA,
		PvGendarmerieA:   acc.PVGendarmerieA,
		VehicleBId:       int64(acc.VehicleBID),
		DriverBId:        int64(acc.DriverBID),
		PointDeChocB:     acc.PointDeChocB,
		DegatsApparentsB: acc.DegatsApparentsB,
		ObservationsB:    acc.ObservationsB,
		PvPoliceB:        acc.PVPoliceB,
		PvGendarmerieB:   acc.PVGendarmerieB,
		Status:           acc.Status,
	}, nil
}

// UpdateAccident
func (h *TwirpAccidentHandler) UpdateAccident(ctx context.Context, req *pb.UpdateAccidentRequest) (*pb.UpdateAccidentResponse, error) {
	r := accident.UpdateAccidentRequest{
		ID: uint(req.Id),
		CreateAccidentRequest: accident.CreateAccidentRequest{
			DateTime:         req.DateTime.AsTime(),
			Location:         req.Location,
			Circonstances:    req.Circonstances,
			VehicleAID:       uint(req.VehicleAId),
			DriverAID:        uint(req.DriverAId),
			PointDeChocA:     req.PointDeChocA,
			DegatsApparentsA: req.DegatsApparentsA,
			ObservationsA:    req.ObservationsA,
			PVPoliceA:        req.PvPoliceA,
			PVGendarmerieA:   req.PvGendarmerieA,
			VehicleBID:       uint(req.VehicleBId),
			DriverBID:        uint(req.DriverBId),
			PointDeChocB:     req.PointDeChocB,
			DegatsApparentsB: req.DegatsApparentsB,
			ObservationsB:    req.ObservationsB,
			PVPoliceB:        req.PvPoliceB,
			PVGendarmerieB:   req.PvGendarmerieB,
			Status:           req.Status,
		},
	}

	acc, err := h.srv.UpdateAccident(r)
	if err != nil {
		return nil, err
	}

	return &pb.UpdateAccidentResponse{
		Id:               int64(acc.ID),
		DateTime:         pbAccidentTimestamp(acc.DateTime),
		Location:         acc.Location,
		Circonstances:    acc.Circonstances,
		VehicleAId:       int64(acc.VehicleAID),
		DriverAId:        int64(acc.DriverAID),
		PointDeChocA:     acc.PointDeChocA,
		DegatsApparentsA: acc.DegatsApparentsA,
		ObservationsA:    acc.ObservationsA,
		PvPoliceA:        acc.PVPoliceA,
		PvGendarmerieA:   acc.PVGendarmerieA,
		VehicleBId:       int64(acc.VehicleBID),
		DriverBId:        int64(acc.DriverBID),
		PointDeChocB:     acc.PointDeChocB,
		DegatsApparentsB: acc.DegatsApparentsB,
		ObservationsB:    acc.ObservationsB,
		PvPoliceB:        acc.PVPoliceB,
		PvGendarmerieB:   acc.PVGendarmerieB,
		Status:           acc.Status,
	}, nil
}

// DeleteAccident
func (h *TwirpAccidentHandler) DeleteAccident(ctx context.Context, req *pb.DeleteAccidentRequest) (*pb.DeleteAccidentResponse, error) {
	r := accident.DeleteAccidentRequest{ID: uint(req.Id)}
	if err := h.srv.DeleteAccident(r); err != nil {
		return nil, err
	}
	return &pb.DeleteAccidentResponse{}, nil
}

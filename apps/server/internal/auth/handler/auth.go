package handler

import (
	"context"

	"github.com/Smart-Accident-Report/costa/internal/auth/service"
	pb "github.com/Smart-Accident-Report/costa/rpc/auth"
)

type TwirpAuthHandler struct {
	srv *service.AuthService
}

func NewTwirpAuthHandler(s *service.AuthService) *TwirpAuthHandler {
	return &TwirpAuthHandler{srv: s}
}

func (h *TwirpAuthHandler) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.RegisterResponse, error) {
	r := service.RegisterRequest{
		Username:          req.Username,
		Password:          req.Password,
		VehicleIDNumber:   req.VehicleIdNumber,
		YearOfCirculation: int(req.YearOfCirculation),
		WilayaNumber:      int(req.WilayaNumber),
		OwnerName:         req.OwnerName,
		OwnerAddress:      req.OwnerAddress,
		ChipSerial:        req.ChipSerial,
	}

	access, refresh, err := h.srv.Register(r)
	if err != nil {
		return nil, err
	}

	return &pb.RegisterResponse{
		AccessToken:  access,
		RefreshToken: refresh,
	}, nil
}

func (h *TwirpAuthHandler) Login(ctx context.Context, req *pb.LoginRequest) (*pb.LoginResponse, error) {
	r := service.LoginRequest{
		Username: req.Username,
		Password: req.Password,
	}

	access, refresh, err := h.srv.Login(r)
	if err != nil {
		return nil, err
	}

	return &pb.LoginResponse{
		AccessToken:  access,
		RefreshToken: refresh,
	}, nil
}

func (h *TwirpAuthHandler) ValidateToken(ctx context.Context, req *pb.ValidateTokenRequest) (*pb.ValidateTokenResponse, error) {
	valid := h.srv.ValidateToken(req.Token)

	return &pb.ValidateTokenResponse{
		Valid: valid,
	}, nil
}



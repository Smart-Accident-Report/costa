package service

import (
	"errors"

	"github.com/Smart-Accident-Report/costa/internal/auth/database/models"
	"github.com/Smart-Accident-Report/costa/internal/auth/utils"
	"gorm.io/gorm"
)

type AuthService struct {
	db *gorm.DB
}

func NewAuthService(db *gorm.DB) *AuthService {
	return &AuthService{db: db}
}

func (s *AuthService) Login(req LoginRequest) (string, string, error) {
	if err := req.Validate(); err != nil {
		return "", "", err
	}

	var user models.User
	if err := s.db.Where("username = ?", req.Username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", "", errors.New("invalid username or password")
		}
		return "", "", err
	}

	if !utils.CheckPasswordHash(req.Password, user.Password) {
		return "", "", errors.New("invalid username or password")
	}

	accessToken, refreshToken, err := utils.GenerateTokenPair(user.Username, user.Username)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

func (s *AuthService) Register(req RegisterRequest) (string, string, error) {
	if err := req.Validate(); err != nil {
		return "", "", err
	}

	var existing models.User
	if err := s.db.Where("username = ?", req.Username).First(&existing).Error; err == nil {
		return "", "", errors.New("username already taken")
	}

	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return "", "", err
	}

	user := &models.User{
		Username:          req.Username,
		Password:          hashedPassword,
		VehicleIDNumber:   req.VehicleIDNumber,
		YearOfCirculation: req.YearOfCirculation,
		WilayaNumber:      req.WilayaNumber,
		OwnerName:         req.OwnerName,
		OwnerAddress:      req.OwnerAddress,
		ChipSerial:        req.ChipSerial,
	}

	if err := s.db.Create(user).Error; err != nil {
		return "", "", err
	}

	accessToken, refreshToken, err := utils.GenerateTokenPair(user.Username, user.Username)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

func (s *AuthService) ValidateToken(token string) bool {
	// Use your JWT validation logic here
	return utils.ValidateJWT(token)
}

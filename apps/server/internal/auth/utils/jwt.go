package utils

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var accessSecretKey = []byte(os.Getenv("JWT_SECRET"))
var refreshSecretKey = []byte(os.Getenv("JWT_SECRET_REFRESH"))

type JWTClaims struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	jwt.RegisteredClaims
}

func GenerateTokenPair(username, email string) (string, string, error) {
	accessClaims := &JWTClaims{
		Username: username,
		Email:    email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(30 * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	accessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString(accessSecretKey)
	if err != nil {
		return "", "", err
	}

	refreshClaims := &JWTClaims{
		Username: username,
		Email:    email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(30 * 24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	refreshToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString(refreshSecretKey)
	if err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

func RefreshAccessToken(refreshToken string) (string, error) {
	claims, err := ValidateToken(refreshToken, true)
	if err != nil {
		return "", err
	}

	newAccessClaims := &JWTClaims{
		Username: claims.Username,
		Email:    claims.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(30 * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	newAccessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, newAccessClaims).SignedString(accessSecretKey)
	if err != nil {
		return "", err
	}

	return newAccessToken, nil
}

func ValidateToken(tokenStr string, isRefresh bool) (*JWTClaims, error) {
	key := accessSecretKey
	if isRefresh {
		key = refreshSecretKey
	}

	parsedToken, err := jwt.ParseWithClaims(tokenStr, &JWTClaims{}, func(t *jwt.Token) (interface{}, error) {
		return key, nil
	})
	if err != nil {
		return nil, err
	}

	claims, ok := parsedToken.Claims.(*JWTClaims)
	if !ok || !parsedToken.Valid {
		return nil, errors.New("invalid or expired JWT token")
	}

	return claims, nil
}

func ValidateJWT(token string) bool {
	_, err := ValidateToken(token, false)
	return err == nil
}

package main

import (
	"log"
	"net/http"

	"github.com/Smart-Accident-Report/costa/internal/auth/database"
	"github.com/Smart-Accident-Report/costa/internal/auth/handler"
	"github.com/Smart-Accident-Report/costa/internal/auth/service"
	pb "github.com/Smart-Accident-Report/costa/rpc/auth"
)

func main() {
	db := database.InitDB()

	authService := service.NewAuthService(db)
	twirpHandler := handler.NewTwirpAuthHandler(authService)

	mux := http.NewServeMux()
	twirpServer := pb.NewAuthServer(twirpHandler)
	mux.Handle(twirpServer.PathPrefix(), twirpServer)

	log.Println("Auth service running on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

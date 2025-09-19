package main

import (
	"log"
	"net/http"

	"github.com/Smart-Accident-Report/costa/internal/Constat/database"
	"github.com/Smart-Accident-Report/costa/internal/Constat/handler"
	"github.com/Smart-Accident-Report/costa/internal/Constat/service/vehicle"
	pb "github.com/Smart-Accident-Report/costa/rpc/vehicle"
)


func main() {
	// Initialize the database
	db := database.InitDB()

	// Initialize the vehicle service
	vehicleService := vehicle.NewVehicleService(db)
	twirpHandler := handler.NewTwirpVehicleHandler(vehicleService)

	// Set up the HTTP server
	mux := http.NewServeMux()
	twirpServer := pb.NewVehicleServiceServer(twirpHandler)
	mux.Handle(twirpServer.PathPrefix(), twirpServer)

	log.Println("Vehicle service running on :8081")
	log.Fatal(http.ListenAndServe(":8081", mux))
}

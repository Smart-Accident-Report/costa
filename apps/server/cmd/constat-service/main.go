package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/Smart-Accident-Report/costa/internal/Constat/database"
	"github.com/Smart-Accident-Report/costa/internal/Constat/handler"
	"github.com/Smart-Accident-Report/costa/internal/Constat/service/accident"
	"github.com/Smart-Accident-Report/costa/internal/Constat/service/insurance"
	"github.com/Smart-Accident-Report/costa/internal/Constat/service/vehicle"
	"github.com/Smart-Accident-Report/costa/internal/config"
	"github.com/Smart-Accident-Report/costa/internal/messaging"
	"github.com/Smart-Accident-Report/costa/internal/storage"
	accidentpb "github.com/Smart-Accident-Report/costa/rpc/accident"
	insurancepb "github.com/Smart-Accident-Report/costa/rpc/insurance"
	vehiclepb "github.com/Smart-Accident-Report/costa/rpc/vehicle"
)

func main() {
	// Initialize configuration
	cfg := config.NewConfig()
	defer cfg.Close()

	// Initialize MinIO
	if err := cfg.InitMinio(); err != nil {
		log.Fatalf("Failed to initialize MinIO: %v", err)
	}

	// Initialize RabbitMQ
	if err := cfg.InitRabbitMQ(); err != nil {
		log.Fatalf("Failed to initialize RabbitMQ: %v", err)
	}

	// Initialize storage service
	storageService := storage.NewMinioStorage(cfg.MinioClient, "costa-files")
	if err := storageService.InitBucket(); err != nil {
		log.Fatalf("Failed to initialize storage bucket: %v", err)
	}

	// Initialize messaging service
	messagingService := messaging.NewRabbitMQService(cfg.RabbitMQCh)

	// Initialize the database
	db := database.InitDB()

	// Initialize services
	vehicleService := vehicle.NewVehicleService(db)
	insuranceService := insurance.NewInsuranceService(db)
	accidentService := accident.NewAccidentService(db)

	// Initialize handlers
	vehicleHandler := handler.NewTwirpVehicleHandler(vehicleService)
	insuranceHandler := handler.NewTwirpInsuranceHandler(insuranceService)
	accidentHandler := handler.NewTwirpAccidentHandler(accidentService)

	// Set up the HTTP server
	mux := http.NewServeMux()

	// Register Twirp servers
	vehicleServer := vehiclepb.NewVehicleServiceServer(vehicleHandler)
	mux.Handle(vehicleServer.PathPrefix(), vehicleServer)

	insuranceServer := insurancepb.NewInsuranceServiceServer(insuranceHandler)
	mux.Handle(insuranceServer.PathPrefix(), insuranceServer)

	accidentServer := accidentpb.NewAccidentServiceServer(accidentHandler)
	mux.Handle(accidentServer.PathPrefix(), accidentServer)

	// Health check endpoint
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	// Start message consumers (example handlers)
	go func() {
		messagingService.ConsumeMessages("accidents", func(body []byte) error {
			log.Printf("Processing accident event: %s", string(body))
			// Add your accident processing logic here
			return nil
		})
	}()

	go func() {
		messagingService.ConsumeMessages("insurance", func(body []byte) error {
			log.Printf("Processing insurance event: %s", string(body))
			// Add your insurance processing logic here
			return nil
		})
	}()

	go func() {
		messagingService.ConsumeMessages("notifications", func(body []byte) error {
			log.Printf("Processing notification event: %s", string(body))
			// Add your notification processing logic here
			return nil
		})
	}()

	// Start HTTP server
	server := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	go func() {
		log.Println("Constat service running on :8080")
		log.Println("Health check available at http://localhost:8080/health")
		log.Println("Vehicle service available at /twirp/vehicle.VehicleService/")
		log.Println("Insurance service available at /twirp/insurance.InsuranceService/")
		log.Println("Accident service available at /twirp/accident.AccidentService/")
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			log.Fatalf("HTTP server error: %v", err)
		}
	}()

	// Graceful shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh

	log.Println("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server shutdown error: %v", err)
	}
	log.Println("Server shutdown complete")
}

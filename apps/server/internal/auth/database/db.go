package database

import (
	"log"
	"os"

	"github.com/Smart-Accident-Report/costa/internal/auth/database/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDB() *gorm.DB {
    dsn := os.Getenv("DB_URL")
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        log.Fatal("failed to connect database:", err)
    }

    // Auto migrate tables
    db.AutoMigrate(&models.User{})

    return db
}

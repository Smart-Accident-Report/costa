package config

import (
	"log"
	"os"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	amqp "github.com/rabbitmq/amqp091-go"
)

type Config struct {
	MinioClient  *minio.Client
	RabbitMQConn *amqp.Connection
	RabbitMQCh   *amqp.Channel
}

func NewConfig() *Config {
	return &Config{}
}

// InitMinio initializes MinIO client
func (c *Config) InitMinio() error {
	endpoint := getEnv("MINIO_ENDPOINT", "localhost:9000")
	accessKeyID := getEnv("MINIO_ACCESS_KEY", "minioadmin")
	secretAccessKey := getEnv("MINIO_SECRET_KEY", "minioadmin123")
	useSSL := false

	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKeyID, secretAccessKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return err
	}

	c.MinioClient = minioClient
	log.Println("MinIO client initialized successfully")
	return nil
}

// InitRabbitMQ initializes RabbitMQ connection and channel
func (c *Config) InitRabbitMQ() error {
	rabbitmqURL := getEnv("RABBITMQ_URL", "amqp://admin:admin123@localhost:5672/")

	conn, err := amqp.Dial(rabbitmqURL)
	if err != nil {
		return err
	}

	ch, err := conn.Channel()
	if err != nil {
		return err
	}

	c.RabbitMQConn = conn
	c.RabbitMQCh = ch

	// Declare basic queues
	queues := []string{"accidents", "insurance", "notifications"}
	for _, queueName := range queues {
		_, err := ch.QueueDeclare(
			queueName, // name
			true,      // durable
			false,     // delete when unused
			false,     // exclusive
			false,     // no-wait
			nil,       // arguments
		)
		if err != nil {
			return err
		}
	}

	log.Println("RabbitMQ connection and queues initialized successfully")
	return nil
}

// Close closes all connections
func (c *Config) Close() {
	if c.RabbitMQCh != nil {
		c.RabbitMQCh.Close()
	}
	if c.RabbitMQConn != nil {
		c.RabbitMQConn.Close()
	}
}

// getEnv gets an environment variable with a fallback default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

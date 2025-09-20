package messaging

import (
	"encoding/json"
	"log"

	amqp "github.com/rabbitmq/amqp091-go"
)

type RabbitMQService struct {
	channel *amqp.Channel
}

func NewRabbitMQService(channel *amqp.Channel) *RabbitMQService {
	return &RabbitMQService{
		channel: channel,
	}
}

// PublishMessage publishes a message to a queue
func (r *RabbitMQService) PublishMessage(queueName string, message interface{}) error {
	body, err := json.Marshal(message)
	if err != nil {
		return err
	}

	err = r.channel.Publish(
		"",        // exchange
		queueName, // routing key
		false,     // mandatory
		false,     // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		})
	if err != nil {
		return err
	}

	log.Printf("Message published to queue %s: %s", queueName, string(body))
	return nil
}

// ConsumeMessages consumes messages from a queue
func (r *RabbitMQService) ConsumeMessages(queueName string, handler func([]byte) error) error {
	msgs, err := r.channel.Consume(
		queueName, // queue
		"",        // consumer
		true,      // auto-ack
		false,     // exclusive
		false,     // no-local
		false,     // no-wait
		nil,       // args
	)
	if err != nil {
		return err
	}

	go func() {
		for d := range msgs {
			log.Printf("Received message from queue %s: %s", queueName, d.Body)
			if err := handler(d.Body); err != nil {
				log.Printf("Error handling message: %v", err)
			}
		}
	}()

	log.Printf("Started consuming messages from queue %s", queueName)
	return nil
}

// Message types for different events
type AccidentCreatedEvent struct {
	AccidentID uint   `json:"accident_id"`
	VehicleAID uint   `json:"vehicle_a_id"`
	VehicleBID uint   `json:"vehicle_b_id"`
	Location   string `json:"location"`
	Status     string `json:"status"`
}

type InsuranceCreatedEvent struct {
	InsuranceID  uint   `json:"insurance_id"`
	VehicleID    uint   `json:"vehicle_id"`
	Company      string `json:"company"`
	PolicyNumber string `json:"policy_number"`
}

type NotificationEvent struct {
	UserID  uint   `json:"user_id"`
	Type    string `json:"type"`
	Message string `json:"message"`
}

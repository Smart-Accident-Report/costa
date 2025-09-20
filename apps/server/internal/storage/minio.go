package storage

import (
	"context"
	"io"

	"github.com/minio/minio-go/v7"
)

type MinioStorage struct {
	client     *minio.Client
	bucketName string
}

func NewMinioStorage(client *minio.Client, bucketName string) *MinioStorage {
	return &MinioStorage{
		client:     client,
		bucketName: bucketName,
	}
}

// InitBucket creates the bucket if it doesn't exist
func (s *MinioStorage) InitBucket() error {
	ctx := context.Background()

	exists, err := s.client.BucketExists(ctx, s.bucketName)
	if err != nil {
		return err
	}

	if !exists {
		err = s.client.MakeBucket(ctx, s.bucketName, minio.MakeBucketOptions{})
		if err != nil {
			return err
		}
	}

	return nil
}

// UploadFile uploads a file to MinIO
func (s *MinioStorage) UploadFile(objectName string, reader io.Reader, objectSize int64, contentType string) error {
	ctx := context.Background()

	_, err := s.client.PutObject(ctx, s.bucketName, objectName, reader, objectSize, minio.PutObjectOptions{
		ContentType: contentType,
	})
	return err
}

// GetFileURL generates a presigned URL for file access
func (s *MinioStorage) GetFileURL(objectName string) (string, error) {
	ctx := context.Background()

	reqParams := make(map[string][]string)
	presignedURL, err := s.client.PresignedGetObject(ctx, s.bucketName, objectName, 3600, reqParams)
	if err != nil {
		return "", err
	}

	return presignedURL.String(), nil
}

// DeleteFile deletes a file from MinIO
func (s *MinioStorage) DeleteFile(objectName string) error {
	ctx := context.Background()

	return s.client.RemoveObject(ctx, s.bucketName, objectName, minio.RemoveObjectOptions{})
}

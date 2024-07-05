package main

import (
  "log"
  "context"
  "strings"

  "github.com/aws/aws-lambda-go/events"
  "github.com/aws/aws-lambda-go/lambda"
  "github.com/aws/aws-sdk-go/service/s3"

  "photo-backup-thumbnail-server/utils"
)

var sourceBucket string = "photo-bucket-travis-linkey"

type Response struct {
  Message string `json:"message"`
}

var s3Client *s3.S3

func init() {
  s3Client = utils.GetS3Client()
}

func Handler(ctx context.Context, s3Event events.S3Event) (Response, error) {
  log.Printf("Recieved s3 Event: %+v", s3Event)

  for _, record := range s3Event.Records {
    s3Entity := record.S3
    bucket := sourceBucket 
    key := s3Entity.Object.Key

    log.Printf("Processed file: s3://%s/%s", bucket, key)

    // Download the image from S3
    img, err := utils.DownloadImage(s3Client, key)
    if err != nil {
      log.Printf("Failed to download image from S3: %v", err)
      continue
    }

    // Create the thumbnail
    thumbnail := utils.CreateThumbnail(img)

    // Upload thumbnail to S3
    thumbKey := strings.Replace(key, ".", "_thumbnail.", 1)
    err = utils.UploadImage(s3Client, thumbKey, thumbnail)
    if err != nil {
      log.Printf("Failed to upload thumbnail to S3: %v", err)
      continue
    }

    log.Printf("Thumbnail created and uploaded to s3://%s/%s", bucket, thumbKey)
  }
  
  return Response{Message: "Request received"}, nil
}

func main() {
  lambda.Start(Handler)
}

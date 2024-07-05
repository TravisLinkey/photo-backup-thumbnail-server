package utils

import (
  "bytes"
  "image"
  "image/png"
  "log"

  "github.com/aws/aws-sdk-go/aws"
  "github.com/aws/aws-sdk-go/aws/session"
  "github.com/aws/aws-sdk-go/service/s3"
)

var sourceBucket string = "photo-backup-travis-linkey"
var destBucket string = "photo-backup-thumbnails"

func GetS3Client() *s3.S3 {
  sess, err := session.NewSession(&aws.Config{
    Region: aws.String("us-west-2"),
  })
  if err != nil {
    ExitErrorf("Unable to create AWS session, %v", err)
  }

  svc := s3.New(sess)
  return svc
}

func DownloadImage(s3Client *s3.S3, key string) (image.Image, error) {
  log.Printf("Processed file: s3://%s/%s", sourceBucket, key)

  result, err := s3Client.GetObject(&s3.GetObjectInput {
    Bucket: aws.String(sourceBucket),
    Key: aws.String(key),
  })

  if err != nil {
    return nil, err
  }

  defer result.Body.Close()

  img, _, err := image.Decode(result.Body)
  if err != nil {
    return nil, err
  }

  return img, nil
}

func UploadImage(s3Client *s3.S3, key string, img image.Image) error {
  var buf bytes.Buffer

  err := png.Encode(&buf, img)
  if err != nil {
    return err
  }

  _, err = s3Client.PutObject(&s3.PutObjectInput{
    Bucket: aws.String(destBucket),
    Key: aws.String(key),
    Body: bytes.NewReader(buf.Bytes()) ,
    ContentType: aws.String("image/png"),
  })

  log.Printf("Successfully uploaded %s to %s", key, destBucket)
  return err
}

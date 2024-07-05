variable "destination_bucket" {
  description = "Bucket to hold the generated thumbnails"
  type = string
}

variable "source_bucket" {
  description = "Bucket containing S3 photos"
  type = string
}

variable "source_bucket_arn" {
  description = "Source bucket arn"
  type = string
}

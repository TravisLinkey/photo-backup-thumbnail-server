resource "aws_s3_bucket" "thumbnail_bucket" {
  bucket = "${var.destination_bucket}"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.thumbnail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.thumbnail_execution_role.arn
        },
        Action = [
          "s3:*"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.thumbnail_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.thumbnail_bucket.id}/*",
        ]
      },
    ]
  })
}

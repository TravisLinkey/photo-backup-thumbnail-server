data "aws_s3_bucket" "source_bucket" {
  bucket = "${var.source_bucket}"
}

resource "aws_lambda_function" "photo_backup_thumbnail_server" {
  function_name    = "photo-backup-thumbnail-server"
  description      = "A lambda to handle creating and uploading thumbnails to s3"
  handler          = "bootstrap"
  runtime          = "provided.al2023"
  role             = aws_iam_role.thumbnail_execution_role.arn
  filename         = "../build/bootstrap.zip"
  source_code_hash = "${base64sha256(filebase64("../build/bootstrap"))}"
  memory_size      = 128
  timeout          = 10
}

# IAM Role for the lambda function to execute
resource "aws_iam_role" "thumbnail_execution_role" {
  name = "thumbnail_execution_role"
  
  assume_role_policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Action: "sts:AssumeRole",
        Effect: "Allow",
        Principal: {
          Service: "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Cloudwatch logs
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs_policy" {
  role = aws_iam_role.thumbnail_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# S3 policy
resource "aws_iam_role_policy" "lambda_s3_permissions" {
  name = "lambda-s3-policy"
  role = aws_iam_role.thumbnail_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AllowS3Access",
        Effect = "Allow",
        Action = [
          "s3:*",
        ],
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*",
        ]
      },
    ]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.thumbnail_execution_role.name
}


# S3 invoke policy
resource "aws_lambda_permission" "allow_bucket_access" {
  statement_id    = "AllowExecutionFromS3Bucket"
  action          = "lambda:InvokeFunction"
  function_name   = aws_lambda_function.photo_backup_thumbnail_server.function_name
  principal       = "s3.amazonaws.com"
  source_arn      = var.source_bucket_arn
}

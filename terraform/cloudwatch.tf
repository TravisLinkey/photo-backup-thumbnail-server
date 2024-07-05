// data "aws_s3_bucket" "source_bucket" {
//   bucket = "${var.source_bucket}"
// }
// 
// # EventBridge policy
// resource "aws_cloudwatch_event_rule" "s3_event_rule" {
//   name = "s3-upload-event"
//   description = "Rule to trigger thumbnail generation on S3 object creation"
//   event_pattern = jsonencode({
//     source: ["aws.s3"],
//     detail-type: ["Object Created"],
//     resources: ["arn:aws:s3:::${data.aws_s3_bucket.source_bucket.arn}"]
//   })
// }
// 
// resource "aws_cloudwatch_event_target" "lambda_target" {
//   rule = aws_cloudwatch_event_rule.s3_event_rule.name
//   target_id = aws_lambda_function.photo_backup_thumbnail_server.id
//   arn = aws_lambda_function.photo_backup_thumbnail_server.arn
// }


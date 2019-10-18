resource "aws_iam_role" "lambda_role" {
    name                = "lambda_role"
    assume_role_policy  = "${file("policies/assume_role_policy.json")}"
}
resource "aws_iam_role_policy" "lambda_policy" {
    name    = "lambda_policy"
    role    = "${aws_iam_role.lambda_role.id}"
    policy  = "${file("policies/iam_role_policy.json")}"
}
provider "aws" {
    region = "us-east-1"
}
locals {
    lambda_zip_location = "outputs/test.zip"
}
data "archive_file" "test" {
    type        = "zip"
    source_file = "test.py"
    output_path = "${local.lambda_zip_location}"
}
resource "aws_lambda_function" "upload_zip" {
    filename            = "${local.lambda_zip_location}"
    function_name       = "test"
    role                = "${aws_iam_role.lambda_role.arn}"
    handler             = "test.salute"

    source_code_hash    = "${filebase64sha256(local.lambda_zip_location)}"
    runtime             = "python3.7"
}
resource "aws_cloudwatch_event_rule" "every_ten_minutes" {
  name                  = "every_ten_minutes"
  description           = "Triggers lambda function every ten minutes."
  schedule_expression   = "rate(10 minutes)"
}
resource "aws_cloudwatch_event_target" "check_upload_every_ten_minutes" {
  rule      = "${aws_cloudwatch_event_rule.every_ten_minutes.name}"
  target_id = "upload_zip"
  arn       = "${aws_lambda_function.upload_zip.arn}"
}
resource "aws_lambda_permission" "allow_cloudwatch_to_call_upload_file" {
    statement_id    = "AllowExecutionFromCloudWatch"
    action          = "lambda:InvokeFunction"
    function_name   = "${aws_lambda_function.upload_zip.function_name}"
    principal       = "events.amazonaws.com"
    source_arn      = "${aws_cloudwatch_event_rule.every_ten_minutes.arn}"
}
# upload zip to s3 and then update lamda function from s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "test-bucket-45678"
  key    = "uploaded_file.py"
  source = "${data.archive_file.test.output_path}" 
  //etag   = "${filemd5("${path.module}/my_files.zip")}"
}
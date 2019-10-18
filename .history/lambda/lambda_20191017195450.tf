provider "aws" {
    region = "us-east-1"
}
resource "aws_lambda_function" "upload_zip" {
    filename            = "${local.lambda_zip_location}"
    function_name       = "test"
    role                = "${aws_iam_role.lambda_role.arn}"
    handler             = "test.salute"

    source_code_hash    = "${filebase64sha256(local.lambda_zip_location)}"
    runtime             = "python3.7"
}
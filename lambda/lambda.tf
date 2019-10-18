provider "aws" {
    region = "us-east-1"
}
locals {
    lambda_zip_file = "outputs/output_file.zip"
}
data "archive_file" "test" {
    type        = "zip"
    source_file = "function_definition.py"
    output_path = "${local.lambda_zip_file}"
}
resource "aws_lambda_function" "my_lambda_function" {
    filename            = "${local.lambda_zip_file}"
    function_name       = "test_function"
    role                = "${aws_iam_role.lambda_role.arn}"
    handler             = "function_definition.function"

    # this should be commented out on first run since outputs directory
    # does not exist initially
    #source_code_hash    = "${filebase64sha256("function_definition.py")}"
    
    runtime             = "python3.7"
}
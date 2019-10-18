provider "aws" {
    region = "us-east-1"
}
resource "aws_lambda_function" "my_lambda_function" {
    function_name       = "test"
    role                = "${aws_iam_role.lambda_role.arn}"
    handler             = "function_definition.function"
    source_code_hash    = "${filebase64sha256("function_definition.py")}"
    runtime             = "python3.7"
}
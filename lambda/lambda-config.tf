# Creates an aws iam role
resource "aws_iam_role" "lambda_role" {
    name                = "lambda_role"
    assume_role_policy  = "${file("../policies/assume_role_policy.json")}"
}
# Creates an aws iam role policy
resource "aws_iam_role_policy" "lambda_policy" {
    name    = "lambda_policy"
    role    = "${aws_iam_role.lambda_role.id}"
    policy  = "${file("../policies/iam_role_policy.json")}"
}

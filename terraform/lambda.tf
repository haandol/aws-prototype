resource "aws_lambda_function" "gs_crawler" {
  role = "${aws_iam_role.lambda_exec_role.arn}"
  function_name = "gs_crawler"
  handler = "lambda.handler"
  runtime = "python3.7"
  filename = "../crawlers/gs_crawler.zip"
  source_code_hash = filebase64sha256("../crawlers/gs_crawler.zip")
}

resource "aws_cloudwatch_event_rule" "every_minute" {
    name = "every-minute"
    description = "Fires every minute"
    schedule_expression = "rate(1 minutes)"
}

resource "aws_cloudwatch_event_target" "crawl_every_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_minute.name}"
    target_id = "gs_crawler"
    arn = "${aws_lambda_function.gs_crawler.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_crawler" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.gs_crawler.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_minute.arn}"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_crawler"
  path = "/"
  description = "Allows Lambda Function"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

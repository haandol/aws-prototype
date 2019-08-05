# IAM Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  path = "/"

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

resource "aws_iam_role_policy" "lambda_log_policy"{
  name = "lambda_log_policy"
  role = "${aws_iam_role.lambda_exec_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# cralwer

resource "aws_lambda_function" "gs_crawler" {
  role = "${aws_iam_role.lambda_exec_role.arn}"
  function_name = "gs_crawler"
  handler = "gs.handler"
  runtime = "python3.7"
  filename = "../crawlers/gs.zip"
  timeout = 30
  source_code_hash = filebase64sha256("../crawlers/gs.zip")
}

resource "aws_cloudwatch_event_rule" "every_minute" {
    name = "every-minute"
    description = "Fires every minute"
    schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "crawl_every_minute" {
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

resource "aws_iam_role_policy" "dynamodb_product_table_policy"{
  name = "dynamodb_product_table_policy"
  role = "${aws_iam_role.lambda_exec_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.product_table.arn}"
    }
  ]
}
EOF
}

# alarm fetcher

resource "aws_lambda_function" "gs_alarm_fetcher" {
  role = "${aws_iam_role.lambda_exec_role.arn}"
  function_name = "gs_alarm_fetcher"
  handler = "gs.handler"
  runtime = "python3.7"
  filename = "../alarms/gs.zip"
  timeout = 30
  source_code_hash = filebase64sha256("../alarms/gs.zip")
}

resource "aws_cloudwatch_event_target" "alarm_every_minute" {
    rule = "${aws_cloudwatch_event_rule.every_minute.name}"
    target_id = "gs_alarm_fetcher"
    arn = "${aws_lambda_function.gs_alarm_fetcher.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_alarm" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.gs_alarm_fetcher.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_minute.arn}"
}

resource "aws_iam_role_policy" "dynamodb_alarm_table_policy"{
  name = "dynamodb_alarm_table_policy"
  role = "${aws_iam_role.lambda_exec_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.alarm_table.arn}"
    }
  ]
}
EOF
}

# alarm sender

resource "aws_lambda_function" "gs_alarm_sender" {
  role = "${aws_iam_role.lambda_exec_role.arn}"
  function_name = "gs_alarm_sender"
  handler = "gs.handler"
  runtime = "python3.7"
  filename = "../consumers/gs.zip"
  timeout = 30
  source_code_hash = filebase64sha256("../consumers/gs.zip")
}

resource "aws_iam_role_policy" "ses_send_mail_policy"{
  name = "ses_send_mail_policy"
  role = "${aws_iam_role.lambda_exec_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# SQS
resource "aws_sqs_queue" "alarm_queue" {
  name = "alarm_queue"
  delay_seconds = 10
  max_message_size = 4096
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.alarm_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.gs_alarm_sender.arn}"
}

resource "aws_iam_role_policy" "sqs_policy" {
  name = "sqs_policy"
  role = "${aws_iam_role.lambda_exec_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:GetQueueAttributes",
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

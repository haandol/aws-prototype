resource "aws_lambda_function" "gs_alarm" {
  role = "${aws_iam_role.lambda_exec_role.arn}"
  function_name = "gs_alarm"
  handler = "alarm.handler"
  runtime = "python3.7"
  filename = "../alarms/gs.zip"
  timeout = 60
  source_code_hash = filebase64sha256("../alarms/gs.zip")
}

resource "aws_cloudwatch_event_rule" "every_minute" {
    name = "every-minute"
    description = "Fires every minute"
    schedule_expression = "rate(2 minutes)"
}

resource "aws_cloudwatch_event_target" "alarm_every_minute" {
    rule = "${aws_cloudwatch_event_rule.every_minute.name}"
    target_id = "gs_alarm"
    arn = "${aws_lambda_function.gs_alarm.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_alarm" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.gs_alarm.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_minute.arn}"
}

resource "aws_iam_role_policy" "dynamodb_alarm_table_policy"{
  name = "dynamodb_alarm_table_polity"
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
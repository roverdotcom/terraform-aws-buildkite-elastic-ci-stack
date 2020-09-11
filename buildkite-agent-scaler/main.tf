data aws_region current {}

locals {
  aws_region        = data.aws_region.current.name
  default_s3_bucket = local.aws_region == "us-east-1" ? "buildkite-lambdas" : "buildkite-lambdas-${local.aws_region}"
  s3_bucket         = var.s3_bucket == "" ? local.default_s3_bucket : var.s3_bucket
  function_name     = var.function_name
}

resource aws_iam_role this {
  name_prefix = format("%s-", local.function_name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_role_policy lambda_autoscaling {
  name = "lambda_autoscaling"
  role = aws_iam_role.this.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:DescribeAutoScalingGroups",
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource aws_lambda_function this {
  function_name = local.function_name
  s3_bucket     = local.s3_bucket
  s3_key        = var.s3_key
  description   = "Parse Cloudflare logs related to workers and send to Datadog"
  timeout       = "120"
  role          = aws_iam_role.this.arn
  handler       = "handler"
  runtime       = "go1.x"
  memory_size   = "128"

  environment {
    variables = {
      BUILDKITE_AGENT_TOKEN = var.buildkite_agent_token
      BUILDKITE_QUEUE       = var.buildkite_queue
      AGENTS_PER_INSTANCE   = format("%s", var.agents_per_instance)
      CLOUDWATCH_METRICS    = format("%s", var.cloudwatch_metrics)
      DISABLE_SCALE_IN      = format("%s", var.disable_scale_in)
      ASG_NAME              = var.asg_name
      MIN_SIZE              = format("%s", var.min_size)
      MAX_SIZE              = format("%s", var.max_size)
      LAMBDA_TIMEOUT        = var.lambda_timeout
      LAMBDA_INTERVAL       = var.lambda_interval
      SCALE_OUT_FACTOR      = var.scale_out_factor
      INCLUDE_WAITING       = format("%s", var.include_waiting)
    }
  }
  depends_on = [aws_cloudwatch_log_group.this]
}

resource aws_cloudwatch_log_group this {
  name              = format("/aws/lambda/%s", local.function_name)
  retention_in_days = 1
}

resource aws_cloudwatch_event_rule every_minute {
  name_prefix         = format("%s-", local.function_name)
  description         = "Fires every minute"
  schedule_expression = "rate(1 minute)"
}

resource aws_cloudwatch_event_target run_cloudflare_workers_datadog_every_minute {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "cloudflare_workers_datadog"
  arn       = aws_lambda_function.this.arn
}

resource aws_lambda_permission lambda_autoscaling_cw_exec {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}

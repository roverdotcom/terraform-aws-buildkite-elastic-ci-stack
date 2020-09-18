variable function_name {
  type = string
}

variable asg_name {
  type = string
}

variable buildkite_queue {
  type = string
}

variable buildkite_agent_token {
  type = string
}

variable min_size {
  type = number
}

variable max_size {
  type = number
}

variable agents_per_instance {
  type = number
}

variable s3_bucket {
  type    = string
  default = ""
}

variable s3_key {
  type    = string
  default = "buildkite-agent-scaler/v1.0.0/handler.zip"
}

variable cloudwatch_metrics {
  type    = bool
  default = true
}

variable disable_scale_in {
  type    = bool
  default = true
}

variable lambda_timeout {
  type    = string
  default = "50s"
}

variable lambda_interval {
  type    = string
  default = "10s"
}

variable scale_out_factor {
  type    = string
  default = "1.0"
}

variable include_waiting {
  type    = bool
  default = false
}

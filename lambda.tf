module autoscaling_lambda {
  source = "./buildkite-agent-scaler"

  function_name         = format("%s-autoscaling", local.name)
  asg_name              = aws_autoscaling_group.main.name
  buildkite_queue       = var.buildkite_queue
  buildkite_agent_token = var.buildkite_agent_token
  min_size              = var.min_size
  max_size              = var.max_size
  agents_per_instance   = var.agents_per_instance
  scale_out_factor      = var.scale_out_factor
  include_waiting       = var.scale_out_for_waiting_jobs
}

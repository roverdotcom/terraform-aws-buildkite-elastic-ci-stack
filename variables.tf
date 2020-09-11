variable name {
  type = string
}

variable buildkite_queue {
  type        = string
  default     = "default"
  description = "Queue name that agents will use, targeted in pipeline steps using 'queue={value}'"
}

variable buildkite_agent_release {
  type    = string
  default = "stable"
}

variable agents_per_instance {
  type    = number
  default = 1
}

variable max_size {
  type    = number
  default = 10
}

variable min_size {
  type    = number
  default = 0
}

variable image_id {
  type    = string
  default = ""
}

variable instance_types {
  type = list
  default = [
    "t2.nano"
  ]
}

variable image_id_parameter {
  type    = string
  default = ""
}

variable key_name {
  default     = ""
  description = "Optional - SSH keypair used to access the buildkite instances, setting this will enable SSH ingress"
}

variable authorized_users_url {
  type        = string
  default     = ""
  description = "Optional - HTTPS or S3 URL to periodically download ssh authorized_keys from, setting this will enable SSH ingress"
}
variable bootstrap_script_url {
  type        = string
  default     = ""
  description = "Optional - HTTPS or S3 URL to run on each instance during boot"
}

variable buildkite_agent_token {
  type        = string
  description = "Buildkite agent registration token"
  default     = ""
}

variable subnets {
  type    = list
  default = []
}

variable vpc_id {
  type = string
}

variable secrets_bucket {
  type    = string
  default = ""
}

variable buildkite_agent_tags {
  type    = string
  default = ""
}

variable security_group_id {
  type        = string
  default     = ""
  description = "Optional - Security group id to assign to instances"
}

variable associate_public_ip_address {
  type        = bool
  default     = true
  description = "Associate instances with public IP addresses"
}

variable root_volume_size {
  type        = number
  default     = 250
  description = "Size of each instance's root EBS volume (in GB)"
}

variable root_volume_name {
  type        = string
  default     = "/dev/xvda"
  description = "Name of the root block device for your AMI"
}

variable root_volume_type {
  type        = string
  default     = "gp2"
  description = "Type of root volume to use"
}

variable enable_ecr_plugin {
  type        = bool
  default     = true
  description = "Enables ecr plugin for all pipelines"
}

variable enable_docker_login_plugin {
  type        = bool
  default     = true
  description = "Enables Docker user namespace remapping so docker runs as buildkite-agent"
}

variable enable_docker_user_namespace_remap {
  type        = bool
  default     = true
  description = "Enables Docker user namespace remapping so docker runs as buildkite-agent"
}

variable enable_docker_experimental {
  type        = bool
  default     = false
  description = "Enables Docker experimental features"
}

variable enable_secrets_plugin {
  type        = bool
  default     = true
  description = "Enables s3-secrets plugin for all pipelines"
}

variable buildkite_agent_timestamp_lines {
  type        = bool
  default     = false
  description = "Set to true to prepend timestamps to every line of output"
}

variable buildkite_additional_sudo_permissions {
  type        = string
  default     = ""
  description = "Optional - Comma separated list of commands to allow the buildkite-agent user to run using sudo."
}

variable scale_in_idle_period {
  type        = number
  default     = 1800
  description = "Number of seconds UnfinishedJobs must equal 0 before scale down"
}

variable scale_out_factor {
  type    = string
  default = "1.0"
}

variable scale_out_for_waiting_jobs {
  type    = bool
  default = false
}

variable ecr_access_policy {
  type        = string
  default     = "none"
  description = "ECR access policy to give container instances"
}

variable buildkite_agent_experiments {
  type        = string
  default     = ""
  description = "Agent experiments to enable, comma delimited. See https://github.com/buildkite/agent/blob/master/EXPERIMENTS.md."
}

variable enable_git_mirrors_experiment {
  type        = bool
  default     = false
  description = "Enables the git-mirrors experiment in the agent"
}

variable on_demand_base_capacity {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  type        = number
  default     = 0
}

variable on_demand_percentage_above_base_capacity {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity."
  type        = number
  default     = 100
}

variable spot_allocation_strategy {
  description = "How to allocate capacity across the Spot pools. Valid values: 'lowest-price', 'capacity-optimized'."
  type        = string
  default     = "capacity-optimized"
}

variable spot_instance_pools {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. Diversifies your Spot capacity across multiple instance types to find the best pricing."
  type        = number
  default     = 2
}

variable spot_price {
  description = "The price to use for reserving spot instances"
  type        = string
  default     = ""
}

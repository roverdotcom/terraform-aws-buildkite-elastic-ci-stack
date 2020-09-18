
locals {
  vpc_id               = var.vpc_id
  build_security_group = var.security_group_id == "" ? 1 : 0

  # Build ssh ingress if we're both making a security group in this module and
  # have either a key_name or authorized users url set.
  build_ssh_ingress = var.security_group_id == "" && (var.key_name != "" || var.authorized_users_url != "") ? 1 : 0

  aws_region = data.aws_region.current.name
  name       = var.name

  # Data used to track along with the built upstream stacks. I'm not convinced
  # this is really the right way to do this.
  ci_stack_data = {
    buildkite_stack_version = "v5.0.0"

    # This selector is derived from the compiled map in the upstream stack's
    # AWSRegion2AMI map. This is going to have to be updated to include the
    # OS type when that lands as a release.
    ami_selector                   = "buildkite-stack-linux-2020-09-08T23-08-45Z*"
    autoscaling_lambda_bucket_name = local.aws_region == "us-east-1" ? "buildkite-lambdas" : "buildkite-lambdas-${local.aws_region}"
    autoscaling_lambda_key         = "buildkite-agent-scaler/v1.0.0/handler.zip"
  }

  image_id = var.image_id == "" ? data.aws_ami.main.image_id : var.image_id
}

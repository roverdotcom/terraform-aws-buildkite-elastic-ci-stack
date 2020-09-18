data aws_region current {}

data aws_ami main {
  most_recent = true
  owners      = ["172840064832"] # Buildkite

  filter {
    name   = "name"
    values = [local.ci_stack_data.ami_selector]
  }
}

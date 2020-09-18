# TODO: All hard-coded things need to be uplifted
# Deal with the fact we're only supporting lambda scaling from v4.5.0
locals {
  userdata = <<-EOF
Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0
--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"
DOCKER_USERNS_REMAP=${var.enable_docker_user_namespace_remap} \
DOCKER_EXPERIMENTAL=${var.enable_docker_experimental} \
  /usr/local/bin/bk-configure-docker.sh
--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash -xv
BUILDKITE_STACK_NAME="${local.name}" \
BUILDKITE_STACK_VERSION=${local.ci_stack_data.buildkite_stack_version} \
BUILDKITE_SCALE_IN_IDLE_PERIOD=${var.scale_in_idle_period} \
BUILDKITE_SECRETS_BUCKET="${var.secrets_bucket}" \
BUILDKITE_AGENT_TOKEN="${var.buildkite_agent_token}" \
BUILDKITE_AGENT_TOKEN_PATH="" \
BUILDKITE_AGENTS_PER_INSTANCE="${var.agents_per_instance}" \
BUILDKITE_AGENT_TAGS="${var.buildkite_agent_tags}" \
BUILDKITE_AGENT_TIMESTAMP_LINES="${var.buildkite_agent_timestamp_lines}" \
BUILDKITE_AGENT_EXPERIMENTS="${var.buildkite_agent_experiments}" \
BUILDKITE_AGENT_RELEASE="${var.buildkite_agent_release}" \
BUILDKITE_QUEUE="${var.buildkite_queue}" \
BUILDKITE_AGENT_ENABLE_GIT_MIRRORS_EXPERIMENT=${var.enable_git_mirrors_experiment} \
BUILDKITE_ELASTIC_BOOTSTRAP_SCRIPT="${var.bootstrap_script_url}" \
BUILDKITE_AUTHORIZED_USERS_URL="${var.authorized_users_url}" \
BUILDKITE_ECR_POLICY=${var.ecr_access_policy} \
BUILDKITE_TERMINATE_INSTANCE_AFTER_JOB=false \
BUILDKITE_ADDITIONAL_SUDO_PERMISSIONS=${var.buildkite_additional_sudo_permissions} \
AWS_DEFAULT_REGION=${local.aws_region} \
SECRETS_PLUGIN_ENABLED=${var.enable_secrets_plugin} \
ECR_PLUGIN_ENABLED=${var.enable_ecr_plugin} \
DOCKER_LOGIN_PLUGIN_ENABLED=${var.enable_docker_login_plugin} \
AWS_REGION=${local.aws_region} \
  /usr/local/bin/bk-install-elastic-stack.sh
--==BOUNDARY==--
EOF
}

resource aws_iam_instance_profile main {
  name_prefix = format("%s-Role-", local.name)
  role        = aws_iam_role.main.name
}

resource aws_security_group main {
  count       = local.build_security_group
  name_prefix = format("%s-", local.name)
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_security_group_rule ssh_ingress {
  count             = local.build_ssh_ingress
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main[0].id
}

resource aws_launch_template main {
  name_prefix            = format("%s-", local.name)
  image_id               = local.image_id
  instance_type          = ""
  ebs_optimized          = true
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }
  key_name = var.key_name

  # TODO: Consider not doing this at all and simply going with the default
  # subnet settings for public ip address. The variable could be used when this
  # module creates the subnets only, otherwise, just take the subnet's default?
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups = [
      (
        var.security_group_id != "" ? var.security_group_id : aws_security_group.main[0].id
      ),
    ]
  }

  block_device_mappings {
    device_name = var.root_volume_name

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
    }
  }

  user_data = base64encode(local.userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_autoscaling_group main {
  name_prefix         = format("%s-", local.name)
  min_size            = var.min_size
  desired_capacity    = 0
  max_size            = var.max_size
  vpc_zone_identifier = var.subnets

  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_types
        content {
          instance_type = override.value
        }
      }
    }

    # Ondemand and spot configuration dependent mostly on var.spot_enabled
    # Follow - https://github.com/HENNGE/terraform-aws-autoscaling-mixed-instances/blob/master/main.tf
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = var.spot_allocation_strategy
      spot_instance_pools                      = var.spot_allocation_strategy == "lowest-price" ? var.spot_instance_pools : null
      spot_max_price                           = var.spot_price
    }
  }
}

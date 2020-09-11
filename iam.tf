resource aws_iam_role main {
  name = format("%s-Role", local.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "autoscaling.amazonaws.com",
            "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# TODO: This is awful, take the real bucket or make one and use that here
resource aws_iam_role_policy s3 {
  name = "s3_all"
  role = aws_iam_role.main.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# TODO: Do the right thing
resource aws_iam_role_policy_attachment ecr {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# TODO: Do the right thing
resource aws_iam_role_policy_attachment asg {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

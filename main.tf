locals {
  vpc_id = "vpc-00000000000" # Enter VPC id to attach too.
}

# Go to Directory Files/Users/
# Get each file that ends with .yaml or .json
locals {
  user_map = {
    for file_key, file in fileset("${path.module}/files/users/", "**/*{.yaml,.json}") :
    # Make key - filename (minus extension) and value the contents of the yaml file.
    trimsuffix(file_key, ".yaml") => yamldecode(templatefile("${path.module}/files/users/${file}", {}))
  }
}

// Choose the subnets that have -private- in their names
data "aws_subnets" "subnet_list" {
  filter {
    name   = "tag:Name"
    values = ["*private*"] # insert subnet values here
  }
}

output "subnets" {
  value = data.aws_subnets.subnet_list.ids
}

resource "aws_security_group" "default" {
  name   = "default-sftp-sg"
  vpc_id = local.vpc_id
  ingress {
    from_port = -1
    protocol  = "ANY"
    to_port   = -1
  }
  egress {
    from_port = -1
    protocol  = "ANY"
    to_port   = -1
  }
}

resource "aws_transfer_server" "sftp_server" {
  endpoint_type          = "VPC"
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]

  endpoint_details {
    vpc_id             = local.vpc_id
    subnet_ids         = data.aws_subnets.subnet_list.ids
    security_group_ids = [aws_security_group.default.id]
  }
  tags = yamldecode(templatefile("${path.module}/files/tags/tags.yaml", {}))
}

# ------------
# Roles
# ------------

# Get Existing iam policies you will need to create them beforehand.
data "aws_iam_role" "existing_roles" {
  for_each = local.user_map
  name     = each.value.role
}

resource "aws_iam_role" "role" {
  name = "default-transfer-user-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
      "Statement": [
          {
          "Effect": "Allow",
          "Principal": {
              "Service": "transfer.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
          }
      ]
  }
  EOF
}

resource "aws_transfer_user" "users" {
  for_each            = local.user_map
  server_id           = aws_transfer_server.sftp_server.id
  user_name           = each.key
  role                = data.aws_iam_role.existing_roles[each.key].arn ## Select role by name each.value.role
  home_directory_type = "PATH"
  home_directory      = "/${each.value.bucket_name}/${each.value.home_directory}"

  tags = {
    owner = each.value.owner
  }
}

resource "aws_transfer_ssh_key" "ssh_keys" {
  for_each  = local.user_map
  user_name = each.key
  body      = each.value.ssh_key
  server_id = aws_transfer_server.sftp_server.id
}
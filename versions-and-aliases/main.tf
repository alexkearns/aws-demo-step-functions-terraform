terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

data "aws_iam_policy_document" "state_machine_role_trust_policy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "state_machine_role" {
  name               = "twitch-demo-state-machine-role"
  assume_role_policy = data.aws_iam_policy_document.state_machine_role_trust_policy.json
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "twitch-demo-state-machine"
  role_arn = aws_iam_role.state_machine_role.arn

  definition = templatefile("./definition.asl.json", {})
}

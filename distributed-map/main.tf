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


resource "aws_s3_bucket" "bucket" {
  bucket        = "twitch-demo-distributed-map-bucket"
  force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "bucket_pab" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "data_source" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "data_source.json"
  source = "./data_source.json"
}

data "aws_iam_policy_document" "state_machine_dist_map_permissions" {
  version = "2012-10-17"

  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [aws_sfn_state_machine.sfn_state_machine.arn]
  }

  statement {
    actions   = ["states:DescribeExecution", "states:StopExecution"]
    effect    = "Allow"
    resources = ["${aws_sfn_state_machine.sfn_state_machine.arn}/*"]
  }
}

data "aws_iam_policy_document" "state_machine_role_permissions" {
  version = "2012-10-17"

  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = [aws_s3_bucket.bucket.arn]
  }
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

resource "aws_iam_policy" "state_machine_dist_map_policy" {
  policy = data.aws_iam_policy_document.state_machine_dist_map_permissions.json
}

resource "aws_iam_policy_attachment" "state_machine_dist_map" {
  name       = "distributed-map-permissions"
  roles      = [aws_iam_role.state_machine_role.name]
  policy_arn = aws_iam_policy.state_machine_dist_map_policy.arn
}

resource "aws_iam_role" "state_machine_role" {
  name               = "twitch-demo-state-machine-role"
  assume_role_policy = data.aws_iam_policy_document.state_machine_role_trust_policy.json
  inline_policy {
    name   = "base-inline-permissions"
    policy = data.aws_iam_policy_document.state_machine_role_permissions.json
  }
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "twitch-demo-state-machine"
  role_arn = aws_iam_role.state_machine_role.arn

  definition = templatefile("./definition.asl.json", {
    bucket    = aws_s3_object.data_source.bucket
    input_key = aws_s3_object.data_source.key
  })
}

provider "aws" {
  region = "eu-central-1"
}
provider "github" {
  owner = "guidion-digital"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }

    github = {
      source  = "integrations/github"
      version = "6.0.0"
    }
  }
}


module "cdn_uploader" {
  source = "../../"

  providers = {
    aws    = aws
    github = github
  }

  username  = "s3-uploader"
  namespace = "github"

  github = {
    repository = "cdn"
    # Requires the environment to exist
    # environment = "prod"
  }

  asm_storage = {
    recovery_window = 0
  }

  policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
  ]

  policies = {
    "cdn_uploads" = {
      Version = "2012-10-17",
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : "s3:ListAllMyBuckets",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObjectAcl",
            "s3:GetObject",
            "s3:DeleteObjectVersion",
            "s3:GetObjectVersionAcl",
            "s3:ListBucket",
            "s3:DeleteObject",
            "s3:PutObjectAcl",
            "s3:GetObjectVersion"
          ],
          "Resource" : [
            "arn:aws:s3:::web-prod-cdn-origin/*",
            "arn:aws:s3:::web-prod-cdn-origin"
          ]
        }
      ]
    }

  }
}

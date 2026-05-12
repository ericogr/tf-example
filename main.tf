# Example Terraform module — no real infrastructure required.
#
# Uses the hashicorp/random provider to generate values without any cloud
# credentials. Safe to lose state: re-applying simply generates new values.
#
# Intended use: referenced by a ResourceSetup via the Tofu Controller
# (totvs.tofu.v1.module driver). Repository: github.com/ericogr/tf-example

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_uuid" "id" {}

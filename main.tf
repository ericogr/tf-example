# Example Terraform module — no real infrastructure required.
#
# Uses the hashicorp/random provider to generate values without any cloud
# credentials. Safe to lose state: re-applying simply generates new values.
#
# terraform_data (built-in since OpenTofu 1.4, no external provider needed)
# adds a lifecycle sentinel tied to var.name via triggers_replace. This
# exercises the full destroy lifecycle without any filesystem state: when
# var.name changes, Terraform plans a replace (delete + create), which is
# blocked by the driver unless allowDestroyOperation is true.
#
# Why terraform_data instead of null_resource / local_file:
# - local_file: wrote state to the runner pod /tmp; the ephemeral Job exits
#   and the file is gone, causing drift on every reconciliation (create loop).
# - null_resource: requires the hashicorp/null provider, which had schema
#   compatibility issues in the runner environment (keepers not recognised).
# - terraform_data: built into OpenTofu, zero provider dependencies, and
#   triggers_replace behaves identically to null_resource keepers.
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

# Lifecycle sentinel — no filesystem state, no drift between runner pods.
# triggers_replace acts as a content-addressable trigger: when var.name
# changes, Terraform plans a replace (actions: ["delete","create"]), which
# the driver classifies as destructive and blocks unless
# allowDestroyOperation is true.
resource "terraform_data" "lifecycle_marker" {
  triggers_replace = {
    name = var.name
  }
}

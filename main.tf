# Example Terraform module — no real infrastructure required.
#
# Uses the hashicorp/random provider to generate values without any cloud
# credentials. Safe to lose state: re-applying simply generates new values.
#
# The hashicorp/null provider adds a null_resource with keepers tied to
# var.name. This exercises the full destroy lifecycle without any filesystem
# state: when var.name changes, Terraform plans a replace (delete + create),
# which is blocked by the driver unless allowDestroyOperation is true.
#
# Why null_resource instead of local_file:
# The Tofu Controller executes Terraform in ephemeral runner Jobs. A local_file
# would be written to the runner pod's /tmp and deleted when the pod exits,
# causing Terraform to detect drift on every reconciliation and re-apply
# in a perpetual create loop. null_resource has no filesystem state, so
# drift detection is always clean between runner pod lifecycles.
#
# Intended use: referenced by a ResourceSetup via the Tofu Controller
# (totvs.tofu.v1.module driver). Repository: github.com/ericogr/tf-example

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
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
# keepers acts as a content-addressable trigger: when var.name changes,
# Terraform plans a replace (actions: ["delete","create"]), which the driver
# classifies as destructive and blocks unless allowDestroyOperation is true.
resource "null_resource" "lifecycle_marker" {
  keepers = {
    name = var.name
  }
}

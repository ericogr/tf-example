# Example Terraform module — no real infrastructure required.
#
# Uses the hashicorp/random provider to generate values without any cloud
# credentials. Safe to lose state: re-applying simply generates new values.
#
# The hashicorp/local provider creates a marker file on the filesystem of
# the Tofu Controller pod. This exercises the full destroy lifecycle:
# on deletion, terraform destroy removes the file, making the teardown
# observable and testable without any cloud credentials.
#
# Intended use: referenced by a ResourceSetup via the Tofu Controller
# (totvs.tofu.v1.module driver). Repository: github.com/ericogr/tf-example

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_uuid" "id" {}

# Marker file — created on apply, deleted on destroy.
# Exercises the full teardown lifecycle without cloud credentials.
resource "local_file" "marker" {
  content = jsonencode({
    name      = var.name
    id        = random_uuid.id.result
    tags      = var.tags
    createdAt = timestamp()
  })
  filename        = "/tmp/tf-marker-${var.name}-${random_string.suffix.result}.json"
  file_permission = "0644"

  lifecycle {
    # timestamp() changes on every plan; ignore it to avoid perpetual drift.
    ignore_changes = [content]
  }
}

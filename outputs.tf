output "resourceName" {
  description = "Generated resource name (prefix + random suffix)."
  value       = "${var.name}-${random_string.suffix.result}"
}

output "resourceId" {
  description = "Unique identifier for this resource instance."
  value       = random_uuid.id.result
}

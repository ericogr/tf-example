output "resourceName" {
  description = "Generated resource name (prefix + random suffix)."
  value       = "${var.name}-${random_string.suffix.result}"
}

output "resourceId" {
  description = "Unique identifier for this resource instance."
  value       = random_uuid.id.result
}

output "markerFilePath" {
  description = "Path of the marker file created on the Tofu Controller pod. Deleted on destroy."
  value       = local_file.marker.filename
}

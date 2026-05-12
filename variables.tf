variable "name" {
  description = "Resource name prefix."
  type        = string
  default     = "test"
}

variable "tags" {
  description = "Metadata tags forwarded from the ResourceSetup runtime context."
  type        = map(string)
  default     = {}
}

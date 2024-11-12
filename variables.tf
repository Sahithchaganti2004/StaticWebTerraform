variable "bucketname2310" {
  default = "myterraformprojectwebsite2023"
}
variable "image_tag" {
  description = "The Docker image tag"
  type        = string
}
variable "app_version" {
  description = "Application version tag for Docker image"
  type        = string
  default     = "1.0.0"  # Update only with significant changes
}

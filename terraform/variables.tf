variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "app_image" {
  description = "Docker image for student management app"
  type        = string
  default     = "student-management-app:latest"
}

variable "app_replicas" {
  description = "Number of replicas for student management app"
  type        = number
  default     = 2
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}

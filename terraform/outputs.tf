output "student_management_service" {
  description = "Student Management Service details"
  value = {
    name = kubernetes_service_v1.student_management_service.metadata[0].name
    port = kubernetes_service_v1.student_management_service.spec[0].port[0].port
  }
}

output "prometheus_service" {
  description = "Prometheus Service details"
  value = {
    name = kubernetes_service_v1.prometheus_service.metadata[0].name
    port = kubernetes_service_v1.prometheus_service.spec[0].port[0].port
    url  = "http://prometheus-service:9090"
  }
}

output "grafana_service" {
  description = "Grafana Service details"
  value = {
    name     = kubernetes_service_v1.grafana_service.metadata[0].name
    port     = kubernetes_service_v1.grafana_service.spec[0].port[0].port
    url      = "http://grafana-service:3000"
    username = "admin"
  }
}

output "prometheus_datasource_url" {
  description = "Prometheus datasource URL for Grafana"
  value       = "http://prometheus-service:9090"
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Student Management App Deployment
resource "kubernetes_deployment_v1" "student_management_app" {
  metadata {
    name      = "student-management-app"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
    labels = {
      app = "student-management"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "student-management"
      }
    }

    template {
      metadata {
        labels = {
          app = "student-management"
        }
      }

      spec {
        container {
          name  = "app"
          image = var.app_image
          port {
            name           = "http"
            container_port = 5000
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          volume_mount {
            name       = "db-data"
            mount_path = "/app/backend/data"
          }
        }

        volume {
          name = "db-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.db_data.metadata[0].name
          }
        }
      }
    }
  }
}

# Student Management Service
resource "kubernetes_service_v1" "student_management_service" {
  metadata {
    name      = "student-management-service"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  spec {
    selector = {
      app = "student-management"
    }

    port {
      name       = "http"
      port       = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

# Persistent Volume Claim for Database
resource "kubernetes_persistent_volume_claim_v1" "db_data" {
  metadata {
    name      = "student-management-pvc"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# Prometheus ConfigMap
resource "kubernetes_config_map_v1" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  data = {
    "prometheus.yml" = file("${path.module}/../monitoring/prometheus-config.yml")
  }
}

# Prometheus Deployment
resource "kubernetes_deployment_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.prometheus.metadata[0].name

        container {
          name  = "prometheus"
          image = "prom/prometheus:latest"

          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--storage.tsdb.path=/prometheus"
          ]

          port {
            name           = "http"
            container_port = 9090
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/prometheus"
          }

          volume_mount {
            name       = "storage"
            mount_path = "/prometheus"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.prometheus_config.metadata[0].name
          }
        }

        volume {
          name = "storage"
          empty_dir {}
        }
      }
    }
  }
}

# Prometheus Service
resource "kubernetes_service_v1" "prometheus_service" {
  metadata {
    name      = "prometheus-service"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  spec {
    selector = {
      app = "prometheus"
    }

    port {
      name       = "http"
      port       = 9090
      target_port = 9090
    }

    type = "LoadBalancer"
  }
}

# Prometheus ServiceAccount and RBAC
resource "kubernetes_service_account_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.prometheus.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.prometheus.metadata[0].name
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }
}

# Grafana Deployment
resource "kubernetes_deployment_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"

          port {
            name           = "http"
            container_port = 3000
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = var.grafana_admin_password
          }

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "storage"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "datasource-config"
            mount_path = "/etc/grafana/provisioning/datasources"
          }
        }

        volume {
          name = "storage"
          empty_dir {}
        }

        volume {
          name = "datasource-config"
          config_map {
            name = kubernetes_config_map_v1.grafana_datasource.metadata[0].name
          }
        }
      }
    }
  }
}

# Grafana Datasource ConfigMap
resource "kubernetes_config_map_v1" "grafana_datasource" {
  metadata {
    name      = "grafana-datasource-config"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  data = {
    "prometheus.yaml" = jsonencode({
      apiVersion = 1
      datasources = [
        {
          name      = "Prometheus"
          type      = "prometheus"
          access    = "proxy"
          url       = "http://prometheus-service:9090"
          isDefault = true
          editable  = true
        }
      ]
    })
  }
}

# Grafana Service
resource "kubernetes_service_v1" "grafana_service" {
  metadata {
    name      = "grafana-service"
    namespace = kubernetes_namespace_v1.default.metadata[0].name
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      name       = "http"
      port       = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

# Default namespace
resource "kubernetes_namespace_v1" "default" {
  metadata {
    name = "default"
  }
}

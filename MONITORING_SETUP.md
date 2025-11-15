# Prometheus & Grafana Monitoring Setup Guide

## Overview

This guide covers setting up Prometheus (metrics collection) and Grafana (visualization) with your Student Management application on Kubernetes using Terraform for infrastructure-as-code.

## Architecture

```
Student Management App → Prometheus → Grafana (Dashboard)
    (/metrics)          (scraping)   (visualization)
```

## Prerequisites

- Kubernetes cluster running
- Terraform v1.0+
- kubectl configured
- Docker image `student-management-app:latest` available in cluster

## Setup Steps

### 1. Install prom-client in Backend

The backend now includes Prometheus metrics. Reinstall dependencies:

```powershell
cd backend
npm install
```

This adds:
- `prom-client` library for metrics
- `/metrics` endpoint on port 5000
- Automatic HTTP request tracking
- Student count gauge

### 2. Deploy with Terraform

**Initialize Terraform:**
```powershell
cd terraform
terraform init
```

**Plan the deployment:**
```powershell
terraform plan
```

**Apply the configuration:**
```powershell
terraform apply
```

This will deploy:
- Student Management app with 2 replicas
- Prometheus for metrics collection
- Grafana for visualization
- All necessary ConfigMaps, Services, and RBAC

**Customize variables (optional):**

Create `terraform.tfvars`:
```hcl
app_image              = "student-management-app:latest"
app_replicas           = 2
grafana_admin_password = "your-secure-password"
kubeconfig_path        = "~/.kube/config"
```

### 3. Verify Deployment

```powershell
kubectl get deployment,svc
kubectl get pods -l app=prometheus
kubectl get pods -l app=grafana
```

### 4. Access Services

**Student Management App:**
```powershell
kubectl port-forward svc/student-management-service 8080:80
# http://localhost:8080
```

**Prometheus:**
```powershell
kubectl port-forward svc/prometheus-service 9090:9090
# http://localhost:9090
```

**Grafana:**
```powershell
kubectl port-forward svc/grafana-service 3000:3000
# http://localhost:3000
# Login: admin / admin (or your custom password)
```

### 5. Configure Grafana Datasource

1. Open Grafana at http://localhost:3000
2. Go to **Configuration → Data Sources**
3. Prometheus should already be added (http://prometheus-service:9090)
4. Click **Test** to verify connection

### 6. Create a Dashboard

**Quick Dashboard:**
1. Click **Create → Dashboard**
2. Add panels with queries:
   - `rate(http_requests_total[5m])` — Request rate
   - `http_request_duration_seconds` — Response time
   - `students_total` — Number of students
   - `process_resident_memory_bytes` — Memory usage

### 7. Available Metrics

**Application Metrics:**
- `http_requests_total` — Total HTTP requests
- `http_request_duration_seconds` — Request duration histogram
- `students_total` — Total students in database

**Node Metrics (automatic):**
- `process_cpu_seconds_total` — CPU time
- `process_resident_memory_bytes` — Memory usage
- `nodejs_heap_size_total_bytes` — Node.js heap size

## Prometheus Configuration

Prometheus scrapes metrics from:
- `http://student-management-service:5000/metrics` (every 10s)
- Kubernetes pods with `prometheus.io/scrape: "true"` annotation

Configuration in `monitoring/prometheus-configmap.yaml`

## Terraform Architecture

**Resources managed by Terraform:**
- Kubernetes Deployments (app, Prometheus, Grafana)
- Services (LoadBalancer)
- ConfigMaps (Prometheus config, Grafana datasource)
- PersistentVolumeClaims (database)
- ServiceAccounts & RBAC (Prometheus)

**Apply/Update infrastructure:**
```powershell
terraform apply
```

**Destroy resources:**
```powershell
terraform destroy
```

## Scaling & Updates

**Scale app replicas:**
```powershell
terraform apply -var="app_replicas=5"
```

**Update Grafana password:**
```powershell
terraform apply -var="grafana_admin_password=NewPassword123"
```

## Monitoring Best Practices

1. **Set up Alerting Rules** — Configure Prometheus alert rules in `prometheus-configmap.yaml`
2. **Create Dashboards** — Build custom dashboards for your team
3. **Set Retention Policy** — Adjust `--storage.tsdb.retention` in Prometheus deployment
4. **Backup Grafana** — Export dashboards and save as JSON

## Troubleshooting

**Prometheus not scraping metrics:**
```powershell
kubectl port-forward svc/prometheus-service 9090:9090
# Check http://localhost:9090/targets
```

**Grafana datasource not working:**
```powershell
kubectl logs -l app=grafana
# Check Service DNS resolution: student-management-service:5000
```

**Metrics endpoint not responding:**
```powershell
kubectl port-forward svc/student-management-service 5000:5000
curl http://localhost:5000/metrics
```

## Clean Up

```powershell
# Destroy all resources
terraform destroy

# Or manually:
kubectl delete deployment prometheus grafana student-management-app
kubectl delete svc prometheus-service grafana-service student-management-service
kubectl delete pvc student-management-pvc
kubectl delete configmap prometheus-config grafana-datasource-config
kubectl delete serviceaccount prometheus
kubectl delete clusterrole prometheus
kubectl delete clusterrolebinding prometheus
```

## Next Steps

1. Create custom dashboards for your app
2. Set up alert rules in Prometheus
3. Configure webhook notifications (Slack, email, etc.)
4. Document your monitoring strategy
5. Train team on using Grafana dashboards

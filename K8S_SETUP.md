# Kubernetes Setup Guide for Student Management System

## Prerequisites
- Kubernetes cluster (v1.20+) — local or cloud-hosted
- `kubectl` installed and configured
- Docker image built and available in your registry or local Docker daemon

## Quick Start

### 1. Build and Push Docker Image

If using a local Kubernetes cluster (minikube, Docker Desktop):
```powershell
# Build image
docker build -t student-management-app:latest .

# For Docker Desktop K8s, image is automatically available
# For minikube, load the image:
minikube image load student-management-app:latest
```

If using a remote registry (Docker Hub, ECR, GCR):
```powershell
docker tag student-management-app:latest <your-registry>/student-management-app:latest
docker push <your-registry>/student-management-app:latest

# Update k8s/deployment.yaml image field to match
```

### 2. Deploy to Kubernetes

**Using kubectl directly:**
```powershell
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

**Using Kustomize (recommended):**
```powershell
kubectl apply -k k8s/
```

### 3. Verify Deployment

```powershell
# Check deployment status
kubectl get deployment student-management-app
kubectl get pods -l app=student-management
kubectl get svc student-management-service

# View logs
kubectl logs -l app=student-management -f

# Describe deployment
kubectl describe deployment student-management-app
```

### 4. Access the Application

**Get the service endpoint:**
```powershell
# For LoadBalancer (cloud providers)
kubectl get svc student-management-service

# For local testing (minikube)
minikube service student-management-service

# For Docker Desktop K8s
kubectl port-forward svc/student-management-service 8080:80
# Then open http://localhost:8080
```

## Kubernetes Resources

### Deployment (deployment.yaml)
- 2 replicas for high availability
- Rolling update strategy
- Liveness & readiness probes
- Resource requests (100m CPU, 128Mi RAM)
- Resource limits (500m CPU, 512Mi RAM)
- Health check via `/health` endpoint

### Service (service.yaml)
- LoadBalancer type for external access
- Exposes port 80, targets port 5000
- Labels for service discovery

### Persistent Volume Claim (pvc.yaml)
- 1Gi storage for SQLite database
- ReadWriteOnce access mode
- Uses standard storage class

### ConfigMap (configmap.yaml)
- NODE_ENV configuration
- Easily modifiable without rebuilding image

### Kustomization (kustomization.yaml)
- Centralized resource management
- Common labels applied automatically
- Replica count configuration

## Scaling

### Scale replicas:
```powershell
kubectl scale deployment student-management-app --replicas=3
```

### Or update kustomization.yaml and reapply:
```yaml
replicas:
- name: student-management-app
  count: 3
```

Then:
```powershell
kubectl apply -k k8s/
```

## Updating the Application

1. Build new image:
```powershell
docker build -t student-management-app:v2 .
docker push <registry>/student-management-app:v2
```

2. Update deployment:
```powershell
kubectl set image deployment/student-management-app \
  app=<registry>/student-management-app:v2
```

Or edit deployment.yaml and reapply:
```powershell
kubectl apply -k k8s/
```

## Cleanup

```powershell
kubectl delete -k k8s/
# Or individually:
kubectl delete deployment student-management-app
kubectl delete svc student-management-service
kubectl delete pvc student-management-pvc
kubectl delete configmap student-management-config
```

## Troubleshooting

### Pod not starting
```powershell
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Image pull errors
- Verify image is available in registry
- Check imagePullPolicy in deployment.yaml (set to IfNotPresent for local images)

### Storage issues
```powershell
kubectl get pvc
kubectl describe pvc student-management-pvc
```

### Service not accessible
```powershell
kubectl port-forward svc/student-management-service 8080:80
# Test: curl http://localhost:8080/health
```

## Production Recommendations

1. **Use specific image tags** instead of `latest`
2. **Set resource limits** based on load testing
3. **Use Ingress** instead of LoadBalancer for cost efficiency
4. **Enable RBAC** and network policies
5. **Use a managed database** (e.g., Cloud SQL, RDS) instead of local SQLite for production
6. **Set up monitoring** with Prometheus/Grafana
7. **Enable pod autoscaling** with HPA:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: student-management-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: student-management-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Local Kubernetes Testing

### Docker Desktop
```powershell
# Enable Kubernetes in Docker Desktop settings
# Then deploy normally
kubectl apply -k k8s/
```

### Minikube
```powershell
# Start minikube
minikube start

# Load image
minikube image load student-management-app:latest

# Deploy
kubectl apply -k k8s/

# Access service
minikube service student-management-service
```

### Kind (Kubernetes in Docker)
```powershell
# Create cluster
kind create cluster --name student-mgmt

# Load image
kind load docker-image student-management-app:latest --name student-mgmt

# Deploy
kubectl apply -k k8s/

# Port forward to access
kubectl port-forward svc/student-management-service 8080:80
```

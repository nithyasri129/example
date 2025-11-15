Student Management Project

Docker
------

Build and run the project with Docker and Docker Compose.

1. Build and start containers:

```powershell
cd c:\\Users\\Nithya\\Downloads\\Student_management
docker compose up -d --build
```

2. The backend API will be reachable at `http://localhost:5000`.

3. Persisting SQLite DB: `students.db` is mounted from the host at `./backend/students.db`.

4. To stop and remove containers:

```powershell
docker compose down
```

Notes
- If `docker compose` is not available, try `docker-compose up -d --build`.
- Ensure Docker Desktop is installed and running.

## Kubernetes

Deploy the project to Kubernetes using the manifests in the `k8s/` folder.

### Quick Start

**Build image:**
```powershell
docker build -t student-management-app:latest .
```

**Deploy with Kustomize:**
```powershell
kubectl apply -k k8s/
```

**Verify:**
```powershell
kubectl get deployment,pods,svc
```

**Access the app:**
```powershell
# For LoadBalancer
kubectl get svc student-management-service

# For local testing (port-forward)
kubectl port-forward svc/student-management-service 8080:80
# Then open http://localhost:8080
```

**Cleanup:**
```powershell
kubectl delete -k k8s/
```

For detailed setup instructions, see [K8S_SETUP.md](K8S_SETUP.md).

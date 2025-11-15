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

# Jenkins Setup Guide for Student Management System

## Prerequisites
- Jenkins installed and running
- Node.js installed on Jenkins agent
- Git installed
- GitHub repository access

## Installation Steps

### 1. Install Jenkins (Windows)
```powershell
# Download from: https://www.jenkins.io/download/
# Run the installer and follow the setup wizard
```

### 2. Create a New Pipeline Job in Jenkins
- Go to Jenkins Dashboard
- Click "New Item"
- Enter Job Name: `Student-Management-Pipeline`
- Select: Pipeline
- Click OK

### 3. Configure Pipeline
- Under "Pipeline" section:
  - Definition: **Pipeline script from SCM**
  - SCM: **Git**
  - Repository URL: `https://github.com/nithyasri129/example.git`
  - Branch: `*/master`
  - Script Path: `Jenkinsfile`

### 4. Build Triggers (Optional)
- Check "GitHub hook trigger for GITScm polling"
- Or use "Poll SCM" and set schedule: `H/15 * * * *` (every 15 minutes)

### 5. Save and Build
- Click "Save"
- Click "Build Now" to run the pipeline

## Pipeline Stages

1. **Checkout** - Clones code from GitHub
2. **Install Dependencies** - Runs `npm install` in backend
3. **Lint Code** - Performs code quality checks
4. **Build** - Builds the application
5. **Test** - Runs test suite
6. **Deploy** - Deploys the application
7. **Notify** - Sends notifications on completion

## Expected Output

```
✅ Pipeline executed successfully!
Project: Student Management System
Status: Ready for deployment
```

## Troubleshooting

### Node.js not found
- Install Node.js on the Jenkins server
- Update PATH in Jenkins system configuration

### Git repository access denied
- Configure SSH keys or GitHub credentials in Jenkins
- Add credentials to the pipeline job

### Port already in use
- Change port in `backend/server.js` to an available port
- Update Jenkinsfile accordingly

## Webhook Setup (Auto-trigger builds on push)

1. Go to GitHub repository settings
2. Click "Webhooks" → "Add webhook"
3. Payload URL: `http://your-jenkins-url/github-webhook/`
4. Content type: `application/json`
5. Select "Just the push event"
6. Click "Add webhook"

Now every push to the repository will automatically trigger a Jenkins build!

## Running Tests Manually

```powershell
cd backend
npm test
```

## Production Deployment

For production, consider:
- Using a process manager like PM2
- Setting up SSL/HTTPS
- Configuring environment variables
- Using a reverse proxy (Nginx)
- Setting up monitoring and logging

# Quiz Journey - Docker Compose

A containerized quiz application with frontend, backend, and nginx reverse proxy.

## Project Structure

```
quizjourney-compose/
├── docker-compose.yaml      # Production setup with Traefik
├── docker-compose.yml       # Development setup with nginx
├── nginx/
│   └── default.conf         # Nginx configuration
├── scripts/
│   └── setup-deployment.sh  # Server setup script
└── .github/
    └── workflows/
        └── main.yml         # Complete CI/CD pipeline
```

## GitHub Actions Workflow

This project includes a comprehensive CI/CD pipeline in `.github/workflows/main.yml`:

### Features:
- **Testing**: Frontend (Node.js) and backend (.NET) testing
- **Building**: Docker image building and pushing to GitHub Container Registry
- **Deployment**: Automatic deployment to staging and production
- **Security**: Vulnerability scanning with Trivy
- **Monitoring**: Health checks and status monitoring
- **Notifications**: Slack notifications for deployment status

### Triggers:
- **Push to `main`** → Deploy to production
- **Push to `develop`** → Deploy to staging
- **Pull Request to `main`** → Test and build only
- **Manual trigger** → Available via workflow_dispatch

## Required GitHub Secrets

To use the GitHub Actions workflow, you need to configure the following secrets in your repository:

### For Production Deployment:
- `HOST`: Production server IP/hostname
- `USERNAME`: SSH username for production server
- `SSH_KEY`: Private SSH key for production server

### For Staging Deployment:
- `STAGING_HOST`: Staging server IP/hostname
- `STAGING_USERNAME`: SSH username for staging server
- `STAGING_SSH_KEY`: Private SSH key for staging server

### For Notifications (Optional):
- `SLACK_WEBHOOK`: Slack webhook URL for deployment notifications

## Setup Instructions

### 1. Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the required secrets listed above

### 2. Set up Deployment Servers

**Production Server:**
```bash
# Create deployment directory
mkdir -p /opt/quizjourney
cd /opt/quizjourney

# Copy docker-compose files
# Ensure the server has Docker and Docker Compose installed
```

**Staging Server:**
```bash
# Create staging directory
mkdir -p /opt/quizjourney-staging
cd /opt/quizjourney-staging

# Copy docker-compose files
# Ensure the server has Docker and Docker Compose installed
```

### 3. Configure SSH Access

Ensure your GitHub Actions can SSH to your deployment servers:

1. Generate SSH key pair if you haven't already
2. Add the public key to your server's `~/.ssh/authorized_keys`
3. Add the private key to GitHub secrets

### 4. Docker Registry Access

The workflows use GitHub Container Registry (ghcr.io). Make sure:
- Your repository has access to push to the registry
- The `GITHUB_TOKEN` secret is available (automatically provided by GitHub)

## Workflow Behavior

### On Push to `main` branch:
1. Test frontend and backend code
2. Build Docker images
3. Push images to GitHub Container Registry
4. Copy files to production server
5. Deploy to production server
6. Run health checks
7. Send notification (if configured)

### On Push to `develop` branch:
1. Test frontend and backend code
2. Build Docker images
3. Push images to GitHub Container Registry
4. Copy files to staging server
5. Deploy to staging server
6. Run health checks
7. Send notification (if configured)

### On Pull Request to `main`:
1. Test frontend and backend code
2. Build Docker images (but don't push)
3. Run security scans

## Customization

### Environment Variables
You can modify the environment variables in the workflow file:
- `REGISTRY`: Container registry URL
- `FRONTEND_IMAGE`: Frontend Docker image name
- `BACKEND_IMAGE`: Backend Docker image name

### Deployment Paths
Update the deployment paths in the workflow file:
- Production: `/opt/quizjourney`
- Staging: `/opt/quizjourney-staging`

### Branch Names
If you use different branch names, update the triggers in the workflow file:
```yaml
on:
  push:
    branches: [ main, develop ]  # Change these to your branch names
```

## Troubleshooting

### Common Issues:

1. **SSH Connection Failed**
   - Verify SSH keys are correctly configured
   - Check server firewall settings
   - Ensure the user has proper permissions

2. **Docker Build Failed**
   - Check if Dockerfile exists in frontend/ and backend/ directories
   - Verify Docker context paths

3. **Deployment Failed**
   - Ensure Docker Compose files are in the correct deployment directories
   - Check if Docker and Docker Compose are installed on the server
   - Verify the deployment user has proper permissions

### Debugging:
- Check the Actions tab in your GitHub repository for detailed logs
- SSH to your deployment server and check Docker logs: `docker-compose logs`

## Security Considerations

1. **Secrets Management**: Never commit secrets to the repository
2. **SSH Keys**: Use dedicated SSH keys for deployment
3. **Registry Access**: Use least-privilege access for container registry
4. **Server Security**: Keep deployment servers updated and secured

## Support

For issues with the GitHub Actions workflows:
1. Check the Actions tab for detailed error messages
2. Verify all secrets are correctly configured
3. Ensure deployment servers are accessible and properly configured 
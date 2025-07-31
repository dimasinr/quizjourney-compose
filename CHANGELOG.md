# Changelog

## [1.0.0] - 2024-01-XX

### Added
- Comprehensive CI/CD pipeline in `.github/workflows/main.yml`
- Server setup script in `scripts/setup-deployment.sh`
- Complete deployment documentation in `DEPLOYMENT.md`
- Health checks and monitoring features
- Security scanning with Trivy
- Slack notifications for deployment status

### Changed
- **BREAKING**: Consolidated multiple workflow files into single `main.yml`
- Removed redundant workflow files:
  - `ci-cd.yml`
  - `docker-deploy.yml` 
  - `deploy-production.yml`
  - `simple-deploy.yml`
  - `deploy-with-files.yml`

### Features
- **Testing**: Frontend (Node.js) and backend (.NET) testing
- **Building**: Docker image building and pushing to GitHub Container Registry
- **Deployment**: Automatic deployment to staging and production
- **Security**: Vulnerability scanning with Trivy
- **Monitoring**: Health checks and status monitoring
- **Notifications**: Slack notifications for deployment status

### Workflow Triggers
- **Push to `main`** → Deploy to production
- **Push to `develop`** → Deploy to staging
- **Pull Request to `main`** → Test and build only
- **Manual trigger** → Available via workflow_dispatch

### Required Secrets
- `HOST`, `USERNAME`, `SSH_KEY` (production)
- `STAGING_HOST`, `STAGING_USERNAME`, `STAGING_SSH_KEY` (staging)
- `SLACK_WEBHOOK` (optional for notifications)

### Deployment Paths
- Production: `/opt/quizjourney`
- Staging: `/opt/quizjourney-staging`

### Security
- SSH key-based authentication
- GitHub Container Registry integration
- Vulnerability scanning
- Health checks and monitoring 
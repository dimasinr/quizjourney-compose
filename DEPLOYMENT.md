# 🚀 Panduan Deployment Quiz Journey

Panduan lengkap untuk menjalankan `docker-compose.yaml` dari GitHub Actions ke server.

## 📋 Prerequisites

### 1. Server Requirements
- Ubuntu/Debian server dengan akses SSH
- Docker dan Docker Compose terinstall
- Traefik (untuk production dengan SSL)
- Port 80 dan 443 terbuka

### 2. GitHub Repository Setup
- Repository dengan struktur project Quiz Journey
- Akses ke GitHub Container Registry
- SSH key untuk deployment

## 🔧 Setup Server

### Step 1: Install Docker dan Docker Compose

Jalankan script setup di server:

```bash
# Download dan jalankan setup script
curl -fsSL https://raw.githubusercontent.com/your-repo/quizjourney-compose/main/scripts/setup-deployment.sh | bash

# Atau jalankan manual:
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

### Step 2: Setup Direktori Deployment

```bash
# Buat direktori deployment
sudo mkdir -p /opt/quizjourney
sudo mkdir -p /opt/quizjourney-staging

# Set ownership
sudo chown $USER:$USER /opt/quizjourney
sudo chown $USER:$USER /opt/quizjourney-staging
```

### Step 3: Setup Traefik (Production)

```bash
# Buat network untuk Traefik
docker network create traefik-public

# Jalankan Traefik
docker run -d \
  --name traefik \
  --network traefik-public \
  -p 80:80 \
  -p 443:443 \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /etc/traefik:/etc/traefik \
  traefik:v2.10 \
  --api.insecure=true \
  --providers.docker=true \
  --providers.docker.exposedbydefault=false \
  --entrypoints.web.address=:80 \
  --entrypoints.websecure.address=:443 \
  --certificatesresolvers.letsencrypt.acme.email=your-email@domain.com \
  --certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme.json \
  --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
```

## 🔐 Konfigurasi GitHub Secrets

### 1. Buka GitHub Repository
- Settings → Secrets and variables → Actions

### 2. Tambahkan Secrets

**Untuk Production:**
```
HOST=your-production-server-ip
USERNAME=your-ssh-username
SSH_KEY=your-private-ssh-key
```

**Untuk Staging:**
```
STAGING_HOST=your-staging-server-ip
STAGING_USERNAME=your-ssh-username
STAGING_SSH_KEY=your-private-ssh-key
```

**Untuk Notifications (Opsional):**
```
SLACK_WEBHOOK=your-slack-webhook-url
```

## 📁 Workflow Files

### 1. Simple Deploy (`.github/workflows/simple-deploy.yml`)
- Deployment sederhana tanpa copy file
- Menggunakan docker-compose yang sudah ada di server
- Cocok untuk setup yang sudah stabil

### 2. Deploy with Files (`.github/workflows/deploy-with-files.yml`)
- Copy file docker-compose.yaml ke server
- Deployment dengan file yang selalu update
- Cocok untuk development yang aktif

### 3. Production Deploy (`.github/workflows/deploy-production.yml`)
- Deployment khusus production
- Health checks dan monitoring
- Notifications lengkap

## 🚀 Cara Deployment

### Method 1: Manual Deployment

```bash
# Di server production
cd /opt/quizjourney
docker-compose pull
docker-compose up -d

# Di server staging
cd /opt/quizjourney-staging
docker-compose pull
docker-compose up -d
```

### Method 2: GitHub Actions (Otomatis)

1. **Push ke branch `main`** → Deploy ke production
2. **Push ke branch `develop`** → Deploy ke staging
3. **Pull Request** → Build dan test saja

### Method 3: Manual Trigger

1. Buka GitHub Actions tab
2. Pilih workflow yang diinginkan
3. Klik "Run workflow"
4. Pilih branch dan klik "Run workflow"

## 📊 Monitoring Deployment

### 1. Check Status di Server

```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs -f

# Check specific service
docker-compose logs -f frontend
docker-compose logs -f backend
```

### 2. Health Checks

```bash
# Check frontend
curl -f http://localhost/ || echo "Frontend down"

# Check backend
curl -f http://localhost:5000/health || echo "Backend down"

# Check with domain
curl -f https://rapid.storyjourney.net/ || echo "Domain not responding"
```

### 3. GitHub Actions Logs

- Buka Actions tab di GitHub
- Klik workflow run yang sedang berjalan
- Lihat logs untuk setiap step

## 🔧 Troubleshooting

### 1. SSH Connection Failed

```bash
# Test SSH connection
ssh -i your-key.pem username@server-ip

# Check SSH key permissions
chmod 600 your-key.pem

# Check server firewall
sudo ufw status
```

### 2. Docker Build Failed

```bash
# Check Dockerfile exists
ls -la frontend/Dockerfile
ls -la backend/Dockerfile

# Check Docker context
docker build -t test ./frontend
```

### 3. Deployment Failed

```bash
# Check server resources
df -h
free -h

# Check Docker status
docker system df
docker system prune -f

# Check container logs
docker-compose logs --tail=50
```

### 4. Service Not Starting

```bash
# Check port conflicts
netstat -tulpn | grep :80
netstat -tulpn | grep :5000

# Check Traefik logs
docker logs traefik

# Check nginx config
docker exec nginx nginx -t
```

## 🔄 Update Process

### 1. Update Images

```bash
# Pull latest images
docker pull ghcr.io/dimasinr/fe-quizjourney:latest
docker pull ghcr.io/dimasinr/be-quizjourney:latest

# Restart services
docker-compose down
docker-compose up -d
```

### 2. Update Configuration

```bash
# Copy new docker-compose.yaml
scp docker-compose.yaml user@server:/opt/quizjourney/

# Restart with new config
cd /opt/quizjourney
docker-compose down
docker-compose up -d
```

### 3. Rollback

```bash
# Rollback to previous image
docker-compose down
docker pull ghcr.io/dimasinr/fe-quizjourney:previous-tag
docker pull ghcr.io/dimasinr/be-quizjourney:previous-tag
docker-compose up -d
```

## 📈 Best Practices

### 1. Security
- Gunakan SSH key, bukan password
- Batasi akses SSH dengan firewall
- Update server secara berkala
- Monitor logs untuk suspicious activity

### 2. Performance
- Gunakan Docker layer caching
- Monitor resource usage
- Clean up unused images secara berkala
- Use health checks

### 3. Monitoring
- Setup log aggregation
- Monitor disk space
- Setup alerts untuk service down
- Regular backup

### 4. CI/CD
- Test di staging sebelum production
- Use semantic versioning
- Document changes
- Monitor deployment metrics

## 🆘 Support

### Common Issues:

1. **Container tidak start**
   - Check logs: `docker-compose logs`
   - Check resources: `docker system df`
   - Check ports: `netstat -tulpn`

2. **SSL certificate issues**
   - Check Traefik logs: `docker logs traefik`
   - Verify domain DNS
   - Check Let's Encrypt rate limits

3. **Performance issues**
   - Monitor CPU/Memory: `htop`
   - Check disk space: `df -h`
   - Optimize Docker images

### Getting Help:

1. Check GitHub Actions logs
2. Check server logs
3. Test connectivity
4. Review configuration files
5. Contact support team

---

**Note:** Pastikan semua secrets sudah dikonfigurasi dengan benar sebelum menjalankan workflow. Test deployment di staging terlebih dahulu sebelum production. 
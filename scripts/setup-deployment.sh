#!/bin/bash

# Setup script untuk deployment Quiz Journey
# Jalankan script ini di server deployment

set -e

echo "🚀 Setting up Quiz Journey deployment..."

# Fungsi untuk menampilkan pesan
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Cek apakah Docker terinstall
if ! command -v docker &> /dev/null; then
    log "❌ Docker tidak terinstall. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    log "✅ Docker berhasil diinstall"
else
    log "✅ Docker sudah terinstall"
fi

# Cek apakah Docker Compose terinstall
if ! command -v docker-compose &> /dev/null; then
    log "❌ Docker Compose tidak terinstall. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log "✅ Docker Compose berhasil diinstall"
else
    log "✅ Docker Compose sudah terinstall"
fi

# Buat direktori deployment
DEPLOY_DIR="/opt/quizjourney"
log "📁 Membuat direktori deployment: $DEPLOY_DIR"
sudo mkdir -p $DEPLOY_DIR
sudo chown $USER:$USER $DEPLOY_DIR

# Buat direktori staging
STAGING_DIR="/opt/quizjourney-staging"
log "📁 Membuat direktori staging: $STAGING_DIR"
sudo mkdir -p $STAGING_DIR
sudo chown $USER:$USER $STAGING_DIR

# Cek apakah Traefik sudah running (untuk production)
if docker ps | grep -q traefik; then
    log "✅ Traefik sudah running"
else
    log "⚠️  Traefik tidak terdeteksi. Pastikan Traefik sudah dikonfigurasi untuk production."
fi

# Test Docker
log "🧪 Testing Docker..."
docker --version
docker-compose --version

# Buat file .env untuk konfigurasi (opsional)
if [ ! -f "$DEPLOY_DIR/.env" ]; then
    log "📝 Membuat file .env template..."
    cat > $DEPLOY_DIR/.env << EOF
# Konfigurasi deployment
ENVIRONMENT=production
DOMAIN=rapid.storyjourney.net

# Docker registry
REGISTRY=ghcr.io
FRONTEND_IMAGE=ghcr.io/dimasinr/fe-quizjourney
BACKEND_IMAGE=ghcr.io/dimasinr/be-quizjourney
EOF
fi

# Buat script untuk update deployment
cat > $DEPLOY_DIR/update.sh << 'EOF'
#!/bin/bash
# Script untuk update deployment

set -e

echo "🔄 Updating Quiz Journey deployment..."

# Pull latest images
docker pull ghcr.io/dimasinr/fe-quizjourney:latest
docker pull ghcr.io/dimasinr/be-quizjourney:latest

# Stop existing containers
docker-compose down --remove-orphans

# Start services
docker-compose up -d

# Wait for services
sleep 30

# Check status
docker-compose ps

echo "✅ Deployment updated successfully!"
EOF

chmod +x $DEPLOY_DIR/update.sh

# Buat script untuk staging
cat > $STAGING_DIR/update.sh << 'EOF'
#!/bin/bash
# Script untuk update staging deployment

set -e

echo "🔄 Updating Quiz Journey staging deployment..."

# Pull latest images
docker pull ghcr.io/dimasinr/fe-quizjourney:latest
docker pull ghcr.io/dimasinr/be-quizjourney:latest

# Stop existing containers
docker-compose down --remove-orphans

# Start services
docker-compose up -d

# Wait for services
sleep 30

# Check status
docker-compose ps

echo "✅ Staging deployment updated successfully!"
EOF

chmod +x $STAGING_DIR/update.sh

log "✅ Setup deployment selesai!"
log ""
log "📋 Langkah selanjutnya:"
log "1. Copy docker-compose.yaml ke $DEPLOY_DIR"
log "2. Copy docker-compose.yaml ke $STAGING_DIR"
log "3. Konfigurasi GitHub Secrets untuk deployment"
log "4. Test deployment dengan menjalankan: $DEPLOY_DIR/update.sh"
log ""
log "🔧 Untuk troubleshooting:"
log "- docker-compose logs -f (untuk melihat logs)"
log "- docker-compose ps (untuk status containers)"
log "- docker system prune -f (untuk cleanup)" 
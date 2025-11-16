#!/bin/bash

# Supernote Private Cloud Setup Script

echo "Setting up Supernote Private Cloud..."

# Create the installation directory
echo "Creating installation directory..."
mkdir -pv /docker/supernote

# Change to installation directory
cd /docker/supernote || exit

# Download database file
echo "Downloading database initialization file..."
curl -O https://supernote-privatecloud.supernote.com/cloud/supernotedb.sql

# Create data persistence paths
echo "Creating data persistence directories..."
mkdir -pv /docker/supernote/sndata/recycle
mkdir -pv /docker/supernote/sndata/logs/cloud
mkdir -pv /docker/supernote/sndata/logs/app
mkdir -pv /docker/supernote/sndata/logs/web
mkdir -pv /docker/supernote/sndata/convert
mkdir -pv /docker/supernote/supernote_data
mkdir -pv /docker/supernote/mariadb_data
mkdir -pv /docker/supernote/redis_data

# Set proper permissions (optional, adjust as needed)
chmod -R 755 /docker/supernote/sndata
chmod -R 755 /docker/supernote/supernote_data

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env in /docker/supernote/"
echo "2. Edit .env and update the following:"
echo "   - MYSQL_ROOT_PASSWORD"
echo "   - MYSQL_USER"
echo "   - MYSQL_PASSWORD"
echo "   - REDIS_PASSWORD"
echo ""
echo "3. From /docker/supernote/, run: docker compose up -d"
echo ""
echo "4. Access the web interface at: http://your-host:19072"
echo "5. Configure your Supernote device to sync with: ws://your-host:18072"

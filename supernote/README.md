# Supernote Private Cloud Docker Deployment

This repository contains Docker Compose configurations for deploying your own Supernote Private Cloud instance.

## Components

The Supernote Private Cloud consists of four main services:

1. **MariaDB 10.6.24** - Database for storing user registration and file synchronization data
2. **Redis 7.4.7** - Cache for storing login credentials and session data
3. **Notelib** - Official Supernote note conversion program
4. **Supernote-Service** - Main Supernote Private Cloud application

## Port Configuration

- **Port 18072**: WebSocket port for automatic synchronization with Supernote devices
- **Port 19072** (configurable): Web management interface (maps to container port 8080)

## Quick Start

### 1. Prerequisites

- Docker and Docker Compose installed on your system
- At least 2GB of available disk space
- Linux/Unix-based system (for timezone configuration)

### 2. Setup

```bash
# Clone or download the configuration files
mkdir -p /docker/supernote
cd /docker/supernote

# Download the database initialization file
curl -O https://supernote-privatecloud.supernote.com/cloud/supernotedb.sql

# Create necessary directories
mkdir -pv /docker/supernote/sndata/{recycle,logs/cloud,logs/app,logs/web,convert}
mkdir -pv /docker/supernote/{supernote_data,mariadb_data,redis_data}

# Copy the environment template
cp .env.example .env
```

### 3. Configuration

Edit the `.env` file and set your passwords:

```bash
# Database Configuration
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_USER=supernote_user
MYSQL_PASSWORD=your_secure_db_password

# Redis Configuration
REDIS_PASSWORD=your_secure_redis_password

# Port Configuration (optional)
WEB_HOST_PORT=19072
SYNC_HOST_PORT=18072
```

### 4. Deploy

```bash
# Start all services
docker compose up -d

# Check service status
docker compose ps

# View logs
docker compose logs -f
```

### 5. Access

- Web Interface: `http://your-server-ip:19072`
- Supernote Device Sync: Configure your device to use `ws://your-server-ip:18072`

### 6. Make public

- Add the appropriate entry to Nginx proxy manager to enable it with the domain

## Directory Structure

```
/docker/supernote/
├── supernotedb.sql             # Database initialization file
├── mariadb_data/               # MariaDB data persistence
├── redis_data/                 # Redis data persistence
├── supernote_data/             # User notes and synchronized files
└── sndata/
    ├── recycle/                # Recycle bin
    ├── convert/                # Converted notes
    └── logs/
        ├── cloud/              # Frontend logs
        ├── app/                # Application logs
        └── web/                # Nginx logs
```

## Maintenance

### Backup

Regular backups should include:
- `mariadb_data/` - Database files
- `redis_data/` - Redis persistence
- `supernote_data/` - User data
- `.env` - Configuration

### Update Services

```bash
# Pull latest images
docker compose pull

# Restart services
docker compose down
docker compose up -d
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f supernote-service
```

### Stop Services

```bash
docker compose down
```

## Troubleshooting

### Services Won't Start

1. Check if ports are already in use:
   ```bash
   netstat -tulpn | grep -E '18072|19072'
   ```

2. Verify Docker network exists:
   ```bash
   docker network ls | grep supernote-net
   ```

3. Check service logs:
   ```bash
   docker compose logs mariadb
   docker compose logs redis
   ```

### Database Connection Issues

- Ensure passwords in `.env` match across all services
- Wait for MariaDB to fully initialize (check health status)
- Verify `supernotedb.sql` was downloaded correctly

### Permission Issues

```bash
# Fix permissions if needed
chmod -R 755 /docker/supernote/sndata /docker/supernote/supernote_data
```

## Security Recommendations

1. **Use Strong Passwords**: Generate secure passwords for all services
2. **Firewall**: Only expose necessary ports (18072, 19072)
3. **HTTPS**: Consider using a reverse proxy (nginx/traefik) with SSL certificates
4. **Regular Updates**: Keep Docker images updated
5. **Backup**: Implement regular backup strategy

## Support

For official support and documentation, visit the Supernote website or consult the original deployment guide.

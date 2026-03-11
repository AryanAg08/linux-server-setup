# 🐳 Multi-User Docker Container System

Complete isolated container environment for multiple users with access control.

---

## 📋 Overview

This system allows you to:
- ✅ Create isolated Docker containers for each user
- ✅ Resource limits per user (CPU, RAM, disk)
- ✅ User-level authentication (password protected)
- ✅ SSH access to containers
- ✅ Web browser terminal access
- ✅ Complete isolation between users
- ✅ Easy management (create, delete, monitor)

**Perfect for:**
- Development environments
- Demo/testing accounts
- Training/workshops
- Multi-tenant applications
- Isolated workspaces

---

## 🚀 Quick Start (10 Minutes)

### Step 1: Install System

```bash
cd ~/devops/scripts

# Initialize multi-user system
sudo ./multi-user-containers.sh init
```

### Step 2: Create First User

```bash
# Create user with default resources (1 CPU, 512MB RAM, 5GB disk)
sudo ./multi-user-containers.sh create-user john

# Or with custom resources
sudo ./multi-user-containers.sh create-user alice \
    --cpu 2.0 \
    --memory 1g \
    --disk 10g \
    --image ubuntu:22.04
```

**Output:**
```
─────────────────────────────────
Username: john
Password: hG8kL3mP9nQ2s
Container: user-john-1234567890

Access commands:
  Shell:  ./multi-user-containers.sh shell john
  Exec:   ./multi-user-containers.sh exec john 'command'
  Logs:   ./multi-user-containers.sh logs john
─────────────────────────────────
```

### Step 3: Access Container

```bash
# Open interactive shell
sudo ./multi-user-containers.sh shell john

# Execute command
sudo ./multi-user-containers.sh exec john 'apt update && apt install -y python3'
```

### Step 4: Setup SSH Gateway (Optional)

```bash
# Setup SSH gateway on port 2222
sudo ./ssh-gateway.sh setup

# Add user's SSH key
sudo ./ssh-gateway.sh add-key john
# Paste public key when prompted

# User can now connect:
ssh -p 2222 john@your-server-ip
```

### Step 5: Setup Web Terminal (Optional)

```bash
# Setup web-based terminal
sudo ./web-terminal-gateway.sh setup

# Start the service
sudo ./web-terminal-gateway.sh start

# Access at: http://your-server-ip:7681
```

---

## 📚 Complete Command Reference

### User Management

```bash
# Create user
sudo ./multi-user-containers.sh create-user <username> [options]

Options:
  --image <image>    Docker image (default: ubuntu:22.04)
  --cpu <limit>      CPU cores (default: 1.0)
  --memory <limit>   RAM limit (default: 512m)
  --disk <limit>     Disk limit (default: 5G)

Examples:
  sudo ./multi-user-containers.sh create-user bob
  sudo ./multi-user-containers.sh create-user alice --memory 2g --cpu 2.0
  sudo ./multi-user-containers.sh create-user dev --image python:3.11

# Delete user
sudo ./multi-user-containers.sh delete-user <username>

# List all users
sudo ./multi-user-containers.sh list-users

# Reset user password
sudo ./multi-user-containers.sh reset-password <username>
```

### Container Operations

```bash
# Start container
sudo ./multi-user-containers.sh start <username>

# Stop container
sudo ./multi-user-containers.sh stop <username>

# Restart container
sudo ./multi-user-containers.sh restart <username>

# Open shell
sudo ./multi-user-containers.sh shell <username>

# Execute command
sudo ./multi-user-containers.sh exec <username> 'command'

Examples:
  sudo ./multi-user-containers.sh exec john 'whoami'
  sudo ./multi-user-containers.sh exec alice 'python3 --version'

# View logs
sudo ./multi-user-containers.sh logs <username> [lines]

Examples:
  sudo ./multi-user-containers.sh logs john
  sudo ./multi-user-containers.sh logs john 100

# Show resource usage
sudo ./multi-user-containers.sh stats <username>
```

### Monitoring

```bash
# Monitor all containers
sudo ./multi-user-containers.sh monitor

# List all users and status
sudo ./multi-user-containers.sh list-users
```

---

## 🔐 Access Methods

### Method 1: Direct Shell (Server Access)

```bash
# From server
sudo ./multi-user-containers.sh shell john
```

**Pros:** Simple, direct  
**Cons:** Requires server access

---

### Method 2: SSH Gateway (Recommended)

**Setup once:**
```bash
sudo ./ssh-gateway.sh setup
```

**Add user's SSH key:**
```bash
sudo ./ssh-gateway.sh add-key john
# Paste user's public key (id_rsa.pub contents)
```

**User connects:**
```bash
ssh -p 2222 john@your-server-ip
# Automatically routed to their container
```

**Pros:** 
- Secure (SSH keys)
- No server password needed
- Standard SSH tools
- Remote access

**Cons:** Requires SSH key management

---

### Method 3: Web Terminal (Browser-Based)

**Setup once:**
```bash
sudo ./web-terminal-gateway.sh setup
sudo ./web-terminal-gateway.sh start
```

**User accesses:**
```
Open browser: http://your-server-ip:7681
Enter username and password
```

**Pros:**
- No SSH client needed
- Works from any device
- Easy for non-technical users

**Cons:** 
- Less secure than SSH
- Requires open port

**Enable HTTPS:**
```bash
sudo ./web-terminal-gateway.sh enable-ssl
# Follow prompts
```

---

## 🎯 Use Cases & Examples

### Use Case 1: Development Environments

```bash
# Create dev environment for each team member
sudo ./multi-user-containers.sh create-user dev1 --image node:20 --memory 1g
sudo ./multi-user-containers.sh create-user dev2 --image python:3.11 --memory 1g
sudo ./multi-user-containers.sh create-user dev3 --image golang:1.21 --memory 1g

# Install tools in each container
sudo ./multi-user-containers.sh exec dev1 'npm install -g typescript'
sudo ./multi-user-containers.sh exec dev2 'pip install django flask'
sudo ./multi-user-containers.sh exec dev3 'go install github.com/goreleaser/goreleaser@latest'
```

---

### Use Case 2: Training Workshop

```bash
# Create 10 student environments
for i in {1..10}; do
    sudo ./multi-user-containers.sh create-user student$i \
        --image ubuntu:22.04 \
        --memory 512m \
        --cpu 0.5
done

# Install workshop materials
for i in {1..10}; do
    sudo ./multi-user-containers.sh exec student$i 'apt update && apt install -y python3 git vim'
done

# Setup SSH access for all
for i in {1..10}; do
    sudo ./ssh-gateway.sh add-key student$i
done
```

---

### Use Case 3: Demo Accounts

```bash
# Create demo account with limited resources
sudo ./multi-user-containers.sh create-user demo \
    --memory 256m \
    --cpu 0.5 \
    --disk 2G

# Pre-install demo software
sudo ./multi-user-containers.sh exec demo '
    apt update
    apt install -y nginx python3 nodejs
    systemctl start nginx
'

# Get credentials
sudo cat /var/lib/user-containers/users/demo/password.txt
```

---

### Use Case 4: Isolated Testing

```bash
# Create test environment
sudo ./multi-user-containers.sh create-user tester --memory 2g

# Run tests in isolation
sudo ./multi-user-containers.sh exec tester '
    git clone https://github.com/your/repo
    cd repo
    npm install
    npm test
'

# View test logs
sudo ./multi-user-containers.sh logs tester
```

---

## 🔒 Security Features

### User Isolation

Each user gets:
- ✅ Separate container
- ✅ Own filesystem
- ✅ Isolated network namespace
- ✅ Resource limits
- ✅ Password authentication
- ✅ Cannot access other users' containers

### Resource Limits

Prevents resource exhaustion:
```bash
# CPU: Limit to X cores
--cpu 1.0  # 100% of 1 CPU core
--cpu 0.5  # 50% of 1 CPU core
--cpu 2.0  # 2 full CPU cores

# Memory: Limit RAM
--memory 512m   # 512 MB
--memory 1g     # 1 GB
--memory 2g     # 2 GB

# Disk: Limit storage
--disk 5G   # 5 GB
--disk 10G  # 10 GB
```

### Access Control

- Passwords hashed with SHA256
- SSH key-based authentication available
- Per-user access logs
- Container-level isolation

### Audit Logging

All access logged to:
- `/var/lib/container-gateway/logs/access.log` (SSH)
- `/var/lib/container-gateway/logs/web-access.log` (Web)
- Container logs viewable with `logs` command

---

## 📊 Monitoring & Management

### Check System Status

```bash
# List all users
sudo ./multi-user-containers.sh list-users

# Monitor all containers
sudo ./multi-user-containers.sh monitor

# Check specific user
sudo ./multi-user-containers.sh stats john
```

### View Logs

```bash
# Container logs
sudo ./multi-user-containers.sh logs john

# SSH access logs
sudo cat /var/lib/container-gateway/logs/access.log

# Web access logs
sudo cat /var/lib/container-gateway/logs/web-access.log

# System logs
sudo journalctl -u web-terminal-gateway -f
```

### Cleanup

```bash
# Delete inactive users
sudo ./multi-user-containers.sh delete-user old-user

# Remove SSH keys
sudo ./ssh-gateway.sh remove-key old-user

# Clean Docker
docker system prune -af
```

---

## 🔧 Advanced Configuration

### Custom Docker Images

```bash
# Use specific images for different users
sudo ./multi-user-containers.sh create-user python-dev --image python:3.11
sudo ./multi-user-containers.sh create-user node-dev --image node:20
sudo ./multi-user-containers.sh create-user rust-dev --image rust:latest
```

### Persistent Data

User data is stored in:
```
/var/lib/user-containers/users/USERNAME/
├── home/        # User's home directory
├── data/        # Shared data folder
├── logs/        # Container logs
└── password.txt # User password (secure)
```

### Resource Monitoring

```bash
# Real-time stats
watch -n 2 'sudo ./multi-user-containers.sh monitor'

# CPU usage only
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}"

# Memory usage only
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
```

---

## 🚨 Troubleshooting

### Container Won't Start

```bash
# Check Docker
sudo systemctl status docker

# Check container logs
sudo docker logs user-username-12345

# Restart container
sudo ./multi-user-containers.sh restart username
```

### SSH Gateway Not Working

```bash
# Check SSH service
sudo systemctl status sshd

# Check gateway port
sudo netstat -tlnp | grep 2222

# Test SSH config
sudo sshd -t

# View SSH logs
sudo tail -f /var/log/auth.log
```

### Web Terminal Not Working

```bash
# Check service
sudo ./web-terminal-gateway.sh status

# View logs
sudo ./web-terminal-gateway.sh logs

# Restart service
sudo ./web-terminal-gateway.sh restart
```

### User Can't Access Container

```bash
# Check if container exists
docker ps -a | grep username

# Check if running
docker ps | grep username

# Start if stopped
sudo ./multi-user-containers.sh start username

# Reset password
sudo ./multi-user-containers.sh reset-password username
```

---

## 💡 Best Practices

1. **Set appropriate resource limits** - Don't give all users unlimited resources
2. **Use SSH keys** for production - More secure than passwords
3. **Enable HTTPS for web terminal** - Protect credentials in transit
4. **Regular backups** - Backup `/var/lib/user-containers/`
5. **Monitor resource usage** - Check for resource exhaustion
6. **Clean up old users** - Remove inactive accounts
7. **Update containers** - Keep base images up to date
8. **Use specific images** - Don't use `latest` tag in production

---

## 📈 Scaling

### Single Server Limits

Typical server can handle:
- 8GB RAM → ~10 users (512MB each)
- 16GB RAM → ~20 users (512MB each)
- 32GB RAM → ~50 users (512MB each)

### Load Balancing (Multiple Servers)

```bash
# Server 1: users 1-10
# Server 2: users 11-20
# Server 3: users 21-30

# Use DNS round-robin or load balancer
```

---

## 🎉 Complete Example Workflow

```bash
# 1. Setup system
cd ~/devops/scripts
sudo ./multi-user-containers.sh init
sudo ./ssh-gateway.sh setup
sudo ./web-terminal-gateway.sh setup
sudo ./web-terminal-gateway.sh start

# 2. Create users
sudo ./multi-user-containers.sh create-user john --memory 1g
sudo ./multi-user-containers.sh create-user alice --memory 1g

# 3. Add SSH keys
sudo ./ssh-gateway.sh add-key john
sudo ./ssh-gateway.sh add-key alice

# 4. Users connect
# John: ssh -p 2222 john@server-ip
# Alice: ssh -p 2222 alice@server-ip
# Or web: http://server-ip:7681

# 5. Monitor
sudo ./multi-user-containers.sh monitor

# 6. Cleanup when done
sudo ./multi-user-containers.sh delete-user john
sudo ./multi-user-containers.sh delete-user alice
```

---

**Location:** `/Users/aryanag/Documents/devops/scripts/`

**Scripts:**
- `multi-user-containers.sh` - Container management
- `ssh-gateway.sh` - SSH access
- `web-terminal-gateway.sh` - Browser access

**All ready to deploy! 🚀**

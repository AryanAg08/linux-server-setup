# 🚀 Multi-User Containers - Quick Start

Get isolated containers for multiple users in 5 minutes.

---

## ⚡ Setup (Admin - One Time)

```bash
cd ~/devops/scripts

# 1. Initialize container system
sudo ./multi-user-containers.sh init

# 2. Setup SSH gateway (port 2222)
sudo ./multi-user-containers.sh setup-ssh

# Done! System is ready.
```

---

## 👥 Create Users (Admin)

```bash
# Create user with defaults (1 CPU, 512MB RAM, 5GB disk)
sudo ./multi-user-containers.sh create-user john

# Custom resources
sudo ./multi-user-containers.sh create-user alice --memory 2g --cpu 2.0 --disk 10g
```

**Output shows:**
- Username
- Initial password
- SSH command to share with user

---

## 🔐 User Access

### Connect via SSH

```bash
# From user's terminal (Windows/Mac/Linux)
ssh -p 2222 john@your-server-ip

# Enter initial password
```

### Change Password (First Login)

```bash
# Once logged in
passwd

# Enter current password
# Enter new password (twice)
```

**Done!** User now has private container with new password.

---

## 📊 Admin Commands

```bash
# List all users
sudo ./multi-user-containers.sh list-users

# Monitor resources
sudo ./multi-user-containers.sh monitor

# View logs
sudo ./multi-user-containers.sh logs john

# Reset password
sudo ./multi-user-containers.sh reset-password john

# Delete user
sudo ./multi-user-containers.sh delete-user john
```

---

## 💡 What Users Get

- ✅ Isolated container (cannot see other users)
- ✅ SSH access from any terminal
- ✅ Can change their own password
- ✅ sudo access (for installing packages)
- ✅ Persistent home directory
- ✅ Resource limits (CPU/RAM/disk)

---

## 📚 Full Documentation

- **SSH Access Guide**: `docs/SSH-ACCESS-GUIDE.md`
- **Multi-User Guide**: `docs/MULTI-USER-CONTAINERS.md`

---

## 🎯 Common Use Cases

### Development Team
```bash
# Create dev environments
sudo ./multi-user-containers.sh create-user dev1 --memory 2g
sudo ./multi-user-containers.sh create-user dev2 --memory 2g

# Each developer gets isolated workspace
# Can install their own tools
# Work independently
```

### Workshop/Training
```bash
# Create 10 student accounts
for i in {1..10}; do
    sudo ./multi-user-containers.sh create-user student$i --memory 512m
done

# Each student:
# - Gets credentials
# - SSH connects: ssh -p 2222 student1@server-ip
# - Changes password
# - Works on assignments
```

### Demo Accounts
```bash
# Temporary demo access
sudo ./multi-user-containers.sh create-user demo --memory 256m --disk 2g

# Share credentials with client
# They can explore safely
# Delete when done
```

---

## 🚨 Troubleshooting

**Can't connect via SSH?**
```bash
# Check SSH service
sudo systemctl status sshd

# Restart SSH
sudo systemctl restart sshd

# Check port
sudo netstat -tlnp | grep 2222
```

**User forgot password?**
```bash
# Admin resets
sudo ./multi-user-containers.sh reset-password username
```

**Container not running?**
```bash
# Start it
sudo ./multi-user-containers.sh start username
```

---

**That's it! Simple SSH-based access with full isolation. 🎉**

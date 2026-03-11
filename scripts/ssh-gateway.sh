#!/bin/bash

# SSH Access Gateway for Multi-User Containers
# Provides SSH access to user containers with automatic routing

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GATEWAY_PORT=2222
GATEWAY_USER="container-gateway"
GATEWAY_HOME="/var/lib/container-gateway"
USERS_DB="/var/lib/user-containers/users.db"

show_help() {
    echo "SSH Gateway for Multi-User Containers"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup              - Install and configure SSH gateway"
    echo "  add-key <user>     - Add SSH public key for user"
    echo "  remove-key <user>  - Remove SSH key for user"
    echo "  list-keys          - List all SSH keys"
    echo "  test <user>        - Test SSH access for user"
    echo ""
    echo "After setup, users can connect with:"
    echo "  ssh -p $GATEWAY_PORT username@your-server-ip"
    echo ""
}

# ============================
# SETUP GATEWAY
# ============================
setup_gateway() {
    echo -e "${BLUE}Setting up SSH Gateway...${NC}"
    
    # Create gateway user
    if ! id "$GATEWAY_USER" &>/dev/null; then
        sudo useradd -r -m -d "$GATEWAY_HOME" -s /bin/bash "$GATEWAY_USER"
        echo "✓ Gateway user created"
    fi
    
    # Create directories
    sudo mkdir -p "$GATEWAY_HOME"/{.ssh,bin,logs}
    sudo touch "$GATEWAY_HOME/logs/access.log"
    
    # Create SSH gateway script
    sudo tee "$GATEWAY_HOME/bin/gateway.sh" > /dev/null << 'EOF'
#!/bin/bash

# SSH Gateway Script - Routes users to their containers

LOG_FILE="/var/lib/container-gateway/logs/access.log"
USERS_DB="/var/lib/user-containers/users.db"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get original username from SSH_ORIGINAL_COMMAND or SSH connection
USERNAME="${SSH_ORIGINAL_COMMAND:-$USER}"
if [ -z "$USERNAME" ]; then
    USERNAME="$USER"
fi

# Log access
log "Access attempt: $USERNAME from ${SSH_CLIENT}"

# Check if user exists
if ! grep -q "^$USERNAME:" "$USERS_DB"; then
    echo "Error: User not found or access denied"
    log "Access denied: $USERNAME (user not found)"
    exit 1
fi

# Get container name
CONTAINER=$(grep "^$USERNAME:" "$USERS_DB" | cut -d: -f2)

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER$"; then
    echo "Starting your container..."
    docker start "$CONTAINER" > /dev/null 2>&1
    sleep 2
fi

# Log successful access
log "Access granted: $USERNAME -> $CONTAINER"

# Connect to container
echo "Connected to your container"
echo ""
docker exec -it -u "$USERNAME" -w "/home/$USERNAME" "$CONTAINER" bash
EOF
    
    sudo chmod +x "$GATEWAY_HOME/bin/gateway.sh"
    
    # Configure SSH for gateway
    if ! grep -q "# Container Gateway Config" /etc/ssh/sshd_config; then
        sudo tee -a /etc/ssh/sshd_config > /dev/null << EOF

# Container Gateway Config
Port $GATEWAY_PORT
Match User $GATEWAY_USER
    ForceCommand $GATEWAY_HOME/bin/gateway.sh
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no
EOF
        
        # Restart SSH
        sudo systemctl restart sshd
        echo "✓ SSH configured (port $GATEWAY_PORT)"
    fi
    
    # Set permissions
    sudo chown -R "$GATEWAY_USER:$GATEWAY_USER" "$GATEWAY_HOME"
    sudo chmod 700 "$GATEWAY_HOME/.ssh"
    
    # Create authorized_keys file
    sudo touch "$GATEWAY_HOME/.ssh/authorized_keys"
    sudo chmod 600 "$GATEWAY_HOME/.ssh/authorized_keys"
    
    # Add firewall rule
    if command -v ufw &> /dev/null; then
        sudo ufw allow $GATEWAY_PORT/tcp comment 'Container Gateway'
        echo "✓ Firewall rule added"
    fi
    
    echo ""
    echo -e "${GREEN}✓ SSH Gateway setup complete${NC}"
    echo ""
    echo "Gateway running on port: $GATEWAY_PORT"
    echo "Users can connect with:"
    echo "  ssh -p $GATEWAY_PORT username@$(hostname -I | awk '{print $1}')"
    echo ""
}

# ============================
# KEY MANAGEMENT
# ============================
add_ssh_key() {
    USERNAME="$1"
    
    if ! grep -q "^$USERNAME:" "$USERS_DB"; then
        echo -e "${RED}✗ User $USERNAME does not exist${NC}"
        return 1
    fi
    
    echo "Enter SSH public key for $USERNAME:"
    echo "(Paste the contents of id_rsa.pub or id_ed25519.pub)"
    echo ""
    read -r SSH_KEY
    
    if [ -z "$SSH_KEY" ]; then
        echo -e "${RED}✗ No key provided${NC}"
        return 1
    fi
    
    # Validate key format
    if ! echo "$SSH_KEY" | grep -qE '^(ssh-rsa|ssh-ed25519|ecdsa-sha2)'; then
        echo -e "${RED}✗ Invalid SSH key format${NC}"
        return 1
    fi
    
    # Add key with forced command
    KEY_LINE="command=\"USER=$USERNAME $GATEWAY_HOME/bin/gateway.sh\" $SSH_KEY"
    
    echo "$KEY_LINE" | sudo tee -a "$GATEWAY_HOME/.ssh/authorized_keys" > /dev/null
    
    echo -e "${GREEN}✓ SSH key added for $USERNAME${NC}"
    echo ""
    echo "User can now connect with:"
    echo "  ssh -p $GATEWAY_PORT $USERNAME@$(hostname -I | awk '{print $1}')"
}

remove_ssh_key() {
    USERNAME="$1"
    
    # Remove all keys for user
    sudo sed -i "/USER=$USERNAME /d" "$GATEWAY_HOME/.ssh/authorized_keys"
    
    echo -e "${GREEN}✓ SSH keys removed for $USERNAME${NC}"
}

list_keys() {
    echo -e "${BLUE}=== Configured SSH Keys ===${NC}"
    echo ""
    
    if [ ! -f "$GATEWAY_HOME/.ssh/authorized_keys" ]; then
        echo "No keys configured"
        return 0
    fi
    
    while IFS= read -r line; do
        if echo "$line" | grep -q "USER="; then
            USERNAME=$(echo "$line" | grep -oP 'USER=\K[^ ]+')
            KEY_TYPE=$(echo "$line" | grep -oP '(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256)')
            echo "  $USERNAME: $KEY_TYPE"
        fi
    done < "$GATEWAY_HOME/.ssh/authorized_keys"
}

test_access() {
    USERNAME="$1"
    
    echo "Testing SSH access for $USERNAME..."
    echo ""
    echo "Run this command from another machine:"
    echo "  ssh -p $GATEWAY_PORT $USERNAME@$(hostname -I | awk '{print $1}')"
    echo ""
    echo "If you have the private key, it should connect directly to the container"
}

# ============================
# MAIN
# ============================

case "$1" in
    setup)
        setup_gateway
        ;;
    add-key)
        add_ssh_key "$2"
        ;;
    remove-key)
        remove_ssh_key "$2"
        ;;
    list-keys)
        list_keys
        ;;
    test)
        test_access "$2"
        ;;
    *)
        show_help
        ;;
esac

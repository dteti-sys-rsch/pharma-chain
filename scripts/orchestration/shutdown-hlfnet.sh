#!/bin/bash

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Run Docker Compose on Main Server in the background
log "Shutdown Docker Compose..."
cd ../../docker && docker compose down

# Hostnames or IP addresses of the two remote hosts
HOST1='novaldy@10.42.10.132'
HOST2='gdputra@10.42.10.131'

# Command to execute on the remote hosts
REMOTE_COMMAND_HOSPITAL='if [ -d ~/pharma-chain/fabric/bc-hospital ] && [ -x ~/pharma-chain/fabric/bc-hospital/network.sh ]; then export PATH=$PATH:$HOME/fabric-samples/bin && cd ~/pharma-chain/fabric/bc-hospital && ./network.sh down; else echo "Required files not found on HOST1"; fi'
REMOTE_COMMAND_INSURANCE='if [ -d ~/pharma-chain/fabric/bc-insurance ] && [ -x ~/pharma-chain/fabric/bc-insurance/network.sh ]; then export PATH=$PATH:$HOME/fabric-samples/bin && cd ~/pharma-chain/fabric/bc-insurance && ./network.sh down; else echo "Required files not found on HOST2"; fi'

# SSH options
SSH_OPTIONS='-o ConnectTimeout=10 -o StrictHostKeyChecking=no'

# Execute command on HOST1
ssh $SSH_OPTIONS $HOST1 "$REMOTE_COMMAND_HOSPITAL"

# Execute command on HOST2
ssh $SSH_OPTIONS $HOST2 "$REMOTE_COMMAND_INSURANCE"

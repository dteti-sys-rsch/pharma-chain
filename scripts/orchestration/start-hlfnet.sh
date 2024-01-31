#!/bin/bash

# Function to log messages
log() {
    echo ""
    echo ""
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Run Docker Compose on Main Server in the background
log "Starting Docker Compose..."
cd ../../docker && docker compose up -d

# Check if Docker Compose started successfully
if [ $? -ne 0 ]; then
    log "Error starting Docker Compose. Exiting script."
    exit 1
fi

# Wait for a moment to ensure Docker Compose has started
sleep 5

# Hostnames or IP addresses of the two remote hosts
HOST1='novaldy@10.42.10.132' # guntur-labse     - bc-hospital
HOST2='gdputra@10.42.10.131' # guntur-labse2    - bc-insurance

# Command to execute on the remote hosts
REMOTE_COMMAND_HOSPITAL='
if [ -d ~/pharma-chain/fabric/bc-hospital ] && [ -x ~/pharma-chain/fabric/bc-hospital/network.sh ];
then
    export PATH=$PATH:$HOME/fabric-samples/bin && cd ~/pharma-chain/fabric/bc-hospital && ./network.sh up createChannel -c hospital -ca;
    sleep 2;
    export PATH=$PATH:$HOME/fabric-samples/bin && cd ~/pharma-chain/fabric/bc-hospital && ./network.sh deployCC -c hospital -ccn hospital-cc -ccp ../chaincode -ccl javascript;
else
    echo "Required files not found on HOST1";
fi'
REMOTE_COMMAND_INSURANCE='
if [ -d ~/pharma-chain/fabric/bc-insurance ] && [ -x ~/pharma-chain/fabric/bc-insurance/network.sh ];
then
    export PATH=$PATH:$HOME/fabric-samples/bin && cd ~/pharma-chain/fabric/bc-insurance && ./network.sh up createChannel -c insurance -ca;
    sleep 2;
    export PATH=$PATH:$HOME/fabric-samples/bin && cd ~/pharma-chain/fabric/bc-insurance && ./network.sh deployCC -c insurance -ccn insurance-cc -ccp ../chaincode -ccl javascript;
else
    echo "Required files not found on HOST2";
fi'

# SSH options
SSH_OPTIONS='-o ConnectTimeout=10 -o StrictHostKeyChecking=no'

log "Starting bc-hospital on guntur-labse ..."
# Execute command on HOST1
ssh $SSH_OPTIONS $HOST1 "$REMOTE_COMMAND_HOSPITAL"

# wait for a few seconds
sleep 2

log "Starting bc-insurance on guntur-labse2 ..."
# Execute command on HOST2
ssh $SSH_OPTIONS $HOST2 "$REMOTE_COMMAND_INSURANCE"

# SSH tunnelling for bc-hospital (guntur-labse) and bc-insurance (guntur-labse2)
log "Starting ssh port tunnelling for bc-hospital and bc-insurance..."
# Kill previous tunnelling
pkill -f "ssh -L"
ssh -L 7050:localhost:7050 -L 7021:localhost:7021 -L 7031:localhost:7031 -N -f $HOST1
ssh -L 7150:localhost:7150 -L 7121:localhost:7121 -L 7131:localhost:7131 -N -f $HOST2

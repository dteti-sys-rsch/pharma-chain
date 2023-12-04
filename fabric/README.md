# Preparation
    # Installing binaries
    curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.14 1.5.7
    export PATH=<path to download location>/bin:$PATH or use edit the system environtmental config
# Running
    # network down
        ./network.sh down

    # network up
        cd ./bc-hospital
        ./network.sh up createChannel -c hospital -ca
        cd ./bc-insurance
        ./network.sh up createChannel -c insurance -ca
        # default cd ./test-network
        ./network.sh up createChannel -c test-network -ca

    # deploy chaincode
        ./network.sh deployCC -ccn namachaincode -ccp ../chaincodes/namafilechaincode/ -ccl javascript

# Port Guidelines
    # Port Orderer: (default 7050)
        hospital = arsada:7051
        insurance = aaui:7052

    # Port CA: (default: (70, 80, 90)54)
        ca_arsada: 12051, 18051
        ca_sardjito: 11051, 17051
        ca_dharmais: 11052, 17052

        ca_aaui: 12052, 18052
        ca_prudential: 11053, 17053
        ca_manulife: 11054, 17054

    # Port Peers: (default 7051)
        orderer.arsada.org:7051
        peer0.sardjito.arsada.org: 10051
        peer0.dharmais.arsada.org: 10052
        peer0.org3.arsada.org: 10055

        orderer.aaui.org:7052
        peer0.prudential.aaui.org: 10053
        peer0.manulife.aaui.org: 10054
        peer0.org3.aaui.org: 10056

# Documentation (ports changes)
## Blockchain bc-hospital
    organization:
    orderer: arsada
    org1: sardjito
    org2: dharmais

#### configtx/configtx.yaml
    Name: ARSADA
    OrdererEndpoints:
        - orderer.arsada.org:7051
#### docker/docker-compose-ca.yaml
    ca_sardjito:
        environment:
            - FABRIC_CA_SERVER_PORT=11051
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:11051
        ports:
            - "11051:11051"
            - "17051:17051"
    ca_dharmais:
        environment:
            - FABRIC_CA_SERVER_PORT=11052
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:11052
        ports:
            - "11052:11052"
            - "17052:17052"
    ca_arsada
        environtment:
            - FABRIC_CA_SERVER_PORT=12051
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:12051
        ports:
            - "12051:12051"
            - "18051:18051"
#### docker/docker-compose-test-net.yaml
    orderer.arsada.org:
        environment:
            - ORDERER_GENERAL_LISTENPORT=7051
        ports:
            - 7051:7051
            - 9443:9443
    peer0.sardjito.arsada.org:
        environment:
            - CORE_PEER_ID=peer0.sardjito.arsada.org
            - CORE_PEER_ADDRESS=peer0.sardjito.arsada.org:10051
            - CORE_PEER_LISTENADDRESS=0.0.0.0:10051
            - CORE_PEER_CHAINCODEADDRESS=peer0.sardjito.arsada.org:10061
            - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:10061
            - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.sardjito.arsada.org:10051
            - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.sardjito.arsada.org:10051
            - CORE_PEER_LOCALMSPID=SardjitoMSP
            - CORE_OPERATIONS_LISTENADDRESS=peer0.sardjito.arsada.org:9444
        ports:
            - 10051:10051
            - 9444:9444
    peer0.dharmais.arsada.org:
        environment:
            - CORE_PEER_ID=peer0.dharmais.arsada.org
            - CORE_PEER_ADDRESS=peer0.dharmais.arsada.org:10052
            - CORE_PEER_LISTENADDRESS=0.0.0.0:10052
            - CORE_PEER_CHAINCODEADDRESS=peer0.dharmais.arsada.org:10062
            - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:10062
            - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.dharmais.arsada.org:10052
            - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.dharmais.arsada.org:10052
            - CORE_PEER_LOCALMSPID=DharmaisMSP
            - CORE_OPERATIONS_LISTENADDRESS=peer0.dharmais.arsada.org:9445
        ports:
            - 10052:10052
            - 9445:9445
#### organizations/ccp-generate.sh
    ORG=sardjito
    ORGMSP=Sardjito
    P0PORT=10051
    CAPORT=11051

    ORG=dharmais
    ORGMSP=Dharmais
    P0PORT=10052
    CAPORT=11052
#### organizations/fabric-ca/registerEnroll.sh
    function createsardjito(): 7054 -> 11051
    function createdharmais(): 8054 ->11052
    function createarsada(): 9054 -> 12051
#### organizations/fabric-ca/
    arsada/fabric-ca-server-config.yaml: port: 7054 -> 12051
    sardjito/fabric-ca-server-config.yaml: port: 7054 -> 11051
    dharmais/fabric-ca-server-config.yaml: port: 7054 -> 11052
#### script/configUpdate.sh
    fetchChannelConfig(): orderer.arsada.org:7051
#### script/createChannel
    function createChannel(): localhost:7051
    commitChaincodeDefinition(): localhost:7051
#### script/deployCC.sh
    approveForMyOrg(): localhost:7051
#### script/envVar.sh
    function setGlobals():
    export CORE_PEER_LOCALMSPID="SardjitoMSP"
    export CORE_PEER_ADDRESS=localhost:10051

    export CORE_PEER_LOCALMSPID="DharmaisMSP"
    export CORE_PEER_ADDRESS=localhost:10052

    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_ADDRESS=localhost:11055

    function setGlobalsCLI():
    if [ $USING_ORG -eq 1 ]; then
      export CORE_PEER_ADDRESS=peer0.sardjito.arsada.org:10051
    elif [ $USING_ORG -eq 2 ]; then
      export CORE_PEER_ADDRESS=peer0.dharmais.arsada.org:10052
    elif [ $USING_ORG -eq 3 ]; then
      export CORE_PEER_ADDRESS=peer0.org3.arsada.org:11055
    else
      errorln "ORG Unknown"
    fi
#### script/scriptAnchorPeer.sh
    if [ $ORG -eq 1 ]; then
        HOST="peer0.sardjito.arsada.org"
        PORT=10051
    elif [ $ORG -eq 2 ]; then
        HOST="peer0.dharmais.arsada.org"
        PORT=10052
    elif [ $ORG -eq 3 ]; then
        HOST="peer0.org3.arsada.org"
        PORT=10055
    else
        errorln "${ORG} unknown"
    fi



## Blockchain bc-insurance
    organization:
    orderer: aaui
    org1: prudential
    org2: manulife
#### configtx/configtx.yaml
    Name: AAUI
    OrdererEndpoints:
        - orderer.aaui.org:7052
#### docker/docker-compose-ca.yaml
    ca_prudential:
        environment:
            - FABRIC_CA_SERVER_PORT=11053
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:11053
        ports:
            - "11053:11053"
            - "17053:17053"
    ca_manulife:
        environment:
            - FABRIC_CA_SERVER_PORT=10054
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:10054
        ports:
            - "10054:10054"
            - "17054:17054"
    ca_aaui
        environtment:
            - FABRIC_CA_SERVER_PORT=12051
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:12051
        ports:
            - "12052:12052"
            - "18052:18052"
#### docker/docker-compose-test-net.yaml
    orderer.aaui.org:
        environment:
            - ORDERER_GENERAL_LISTENPORT=7052
        ports:
            - 7052:7052
            - 9446:9446
    peer0.prudential.aaui.org:
        environment:
            - CORE_PEER_ID=peer0.prudential.aaui.org
            - CORE_PEER_ADDRESS=peer0.prudential.aaui.org:10053
            - CORE_PEER_LISTENADDRESS=0.0.0.0:10053
            - CORE_PEER_CHAINCODEADDRESS=peer0.prudential.aaui.org:10063
            - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:10063
            - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.prudential.aaui.org:10053
            - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.prudential.aaui.org:10053
            - CORE_PEER_LOCALMSPID=PrudentialMSP
            - CORE_OPERATIONS_LISTENADDRESS=peer0.prudential.aaui.org:9447
        ports:
            - 10053:10053
            - 9447:9447
    peer0.manulife.aaui.org:
        environment:
            - CORE_PEER_ID=peer0.manulife.aaui.org
            - CORE_PEER_ADDRESS=peer0.manulife.aaui.org:10054
            - CORE_PEER_LISTENADDRESS=0.0.0.0:10054
            - CORE_PEER_CHAINCODEADDRESS=peer0.manulife.aaui.org:10064
            - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:10064
            - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.manulife.aaui.org:10054
            - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.manulife.aaui.org:10054
            - CORE_PEER_LOCALMSPID=ManulifeMSP
            - CORE_OPERATIONS_LISTENADDRESS=peer0.manulife.aaui.org:9448
        ports:
            - 10054:10054
            - 9448:9448
#### organizations/ccp-generate.sh
    ORG=prudential
    ORGMSP=Prudential
    P0PORT=10053
    CAPORT=11053

    ORG=manulife
    ORGMSP=Manulife
    P0PORT=10054
    CAPORT=11054
#### organizations/fabric-ca/registerEnroll.sh
    function createprudential(): 7054 -> 11053
    function createmanulife(): 8054 ->11054
    function createaaui(): 9054 -> 12052
#### organizations/fabric-ca/
    aaui/fabric-ca-server-config.yaml: port: 7054 -> 12052
    prudential/fabric-ca-server-config.yaml: port: 7054 -> 11053
    manulife/fabric-ca-server-config.yaml: port: 7054 -> 11054
#### script/configUpdate.sh
    fetchChannelConfig(): orderer.aaui.org:7052
#### script/createChannel
    function createChannel(): localhost:7052
#### script/deployCC.sh
    approveForMyOrg(): localhost:7052
    commitChaincodeDefinition(): localhost:7052
#### script/envVar.sh
    function setGlobals():
    export CORE_PEER_LOCALMSPID="PrudentialMSP"
    export CORE_PEER_ADDRESS=localhost:10053

    export CORE_PEER_LOCALMSPID="ManulifeMSP"
    export CORE_PEER_ADDRESS=localhost:10054

    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_ADDRESS=localhost:10056

    function setGlobalsCLI():
    if [ $USING_ORG -eq 1 ]; then
      export CORE_PEER_ADDRESS=peer0.prudential.aaui.org:10053
    elif [ $USING_ORG -eq 2 ]; then
      export CORE_PEER_ADDRESS=peer0.manulife.aaui.org:10054
    elif [ $USING_ORG -eq 3 ]; then
      export CORE_PEER_ADDRESS=peer0.org3.aaui.org:10056
    else
      errorln "ORG Unknown"
    fi
#### script/scriptAnchorPeer.sh
    if [ $ORG -eq 1 ]; then
        HOST="peer0.prudential.aaui.org"
        PORT=10053
    elif [ $ORG -eq 2 ]; then
        HOST="peer0.manulife.aaui.org"
        PORT=10054
    elif [ $ORG -eq 3 ]; then
        HOST="peer0.org3.aaui.org"
        PORT=10056
    else
        errorln "${ORG} unknown"
    fi

# Guide
    1. configtx.yaml
        Name: OrdererOrg
        OrdererEndpoints:
            - orderer.example.com:7050 (ARSADA: 7051, AAUI: 7052)
    2. docker-compose-ca.yaml
        ca_org1:
        - environment
            - FABRIC_CA_SERVER_PORT=7054
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:17054
        - ports:
            - "7054:7054" (ca_sardjito: 11051, 17051, ca_prudential: 11053, 17053)
            - "17054:17054"
        ca_org2:
        - environment
            - FABRIC_CA_SERVER_PORT=8054
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:18054
        - ports:
            - "8054:8054" (ca_dharmais: 11052, 17052, ca_manulife: 11054, 17054)
            - "18054:18054"
        ca_orderer:
        - environment
            - FABRIC_CA_SERVER_PORT=9054
            - FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:19054
        - ports:
            - "9054:9054" (ca_arsada: 12051, 18051, ca_aaui: 12052, 18052)
            - "19054:19054"
    3. docker-compose-test-net.yaml
        orderer.example.com:
            environment:
                - ORDERER_GENERAL_LISTENPORT=7050
                - ORDERER_OPERATIONS_LISTENADDRESS=orderer.example.com:9443
            ports:
                - 7050:7050
                - 9443:9443
        peer0.org1.example.com:
            environment:
                - CORE_PEER_ID=peer0.org1.example.com
                - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
                - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
                - CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
                - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
                - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
                - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
                - CORE_PEER_LOCALMSPID=Org1MSP
                - CORE_OPERATIONS_LISTENADDRESS=peer0.org1.example.com:9444
            ports:
                - 7051:7051
                - 9444:9444
        peer0.org2.example.com:
            environment:
                - CORE_PEER_ID=peer0.org2.example.com
                - CORE_PEER_ADDRESS=peer0.org2.example.com:9051
                - CORE_PEER_LISTENADDRESS=0.0.0.0:9051
                - CORE_PEER_CHAINCODEADDRESS=peer0.org2.example.com:9052
                - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:9052
                - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
                - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.example.com:9051
                - CORE_PEER_LOCALMSPID=Org2MSP
                - CORE_OPERATIONS_LISTENADDRESS=peer0.org2.example.com:9445
            ports:
                - 9051:9051
                - 9445:9445
    4. ccp-generate.sh
        ORG=1
        P0PORT=7051 (peer0.org1.example.com:7051)
        CAPORT=7054 (ca_org1: 7054)

        ORG=2
        P0PORT=9051 (peer0.org2.example.com:9051)
        CAPORT=8054 (ca_org2: 8054)
    5. fabric-ca/ordererOrg, org1, org2
        port: 7054
    6. fabric-ca/registerEnroll.sh
        function createOrg1(): 7054
        function createOrg2(): 8054
        function createOrderer(): 9054
    7. script/configUpdate.sh
        orderer.example.com:7050 (OrdererEndpoints port)
    8. script/createChannel
        localhost:7050 (OrdererEndpoints port)
    9. script/deployCC.sh
        localhost:7050 (OrdererEndpoints port)
    10. script/envVar.sh
        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_ADDRESS=localhost:7051 (peer0.org1.example.com:7051)
        
        export CORE_PEER_LOCALMSPID="Org2MSP"
        export CORE_PEER_ADDRESS=localhost:9051 (peer0.org2.example.com:9051)

        export CORE_PEER_LOCALMSPID="Org3MSP"
        export CORE_PEER_ADDRESS=localhost:11051 (peer0.org3.example.com:11051)
    11. scriptAnchorPeer.sh
        HOST="peer0.org1.example.com"
        PORT=7051 (peer0.org1.example.com:7051)

        HOST="peer0.org2.example.com"
        PORT=9051 (peer0.org2.example.com:9051)

        HOST="peer0.org3.example.com"
        PORT=11051 (peer0.org3.example.com:11051)
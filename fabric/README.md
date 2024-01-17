# Preparation

    # Installing binaries
    curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.14 1.5.7
    export PATH=<path to download location>/bin:$PATH or use edit the system environtmental config

# Running

    # network up
        # default on test-network
        cd ./test-network
        ./network.sh up createChannel -c mychannel -ca

        # for use :
        cd ./bc-hospital
        ./network.sh up createChannel -c hospital -ca
        cd ./bc-insurance
        ./network.sh up createChannel -c insurance -ca

    # deploy chaincode
        example: ./network.sh deployCC -ccn namachaincode -ccp ../chaincodes/namafilechaincode/ -ccl javascript
        test-network: ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript -ccl javascript

        # for use :
        hospital: ./network.sh deployCC -c hospital -ccn hospitalCC -ccp ../chaincode -ccl javascript
        insurance: ./network.sh deployCC -c insurance -ccn insuranceCC -ccp ../chaincode -ccl javascript

    # network down on each folder (bc-hospital and bc-insurance)
        ./network.sh down


# Port Guidelines

    # Port Orderer: (default 7050)
        hospital = arsada:7050
        insurance = aaui:7150

    # Port CA: (default: (70, 80, 90)54)
        ca_arsada: 7010
        ca_org1: 7011
        ca_org2: 7012

        ca_aaui: 7110
        ca_org4: 7111
        ca_org5: 7112

    # Port Peers: (default 7051)
        arsada.hospital.com:7050
        peer0.org1.hospital.com: 7021 & 7022
        peer0.org2.hospital.com: 7031 & 7032
        peer0.org3.hospital.com: 7041 & 7042

        aaui.insurance.com:7150
        peer0.org4.insurance.com: 7121 & 7122
        peer0.org5.insurance.com: 7131 & 7132
        peer0.org6.insurance.com: 7141 & 7142

# Folder changes

## Blockchain bc-hospital and bc-insurance

    configtx/configtx.yaml
    docker/docker-compose-ca.yaml
    docker/docker-compose-couch.yaml
    docker/docker-compose-test-net.yaml
    organizations/ccp-generate.sh
    organizations/fabric-ca/registerEnroll.sh
    organizations/fabric-ca/
    script/configUpdate.sh
    script/createChannel
    script/deployCC.sh
    script/envVar.sh
    script/scriptAnchorPeer.sh

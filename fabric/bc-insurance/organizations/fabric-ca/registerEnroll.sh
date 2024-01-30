#!/bin/bash

function createOrg4() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org4.insurance.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org4.insurance.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@10.42.10.131:7111 --caname ca-org4 --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/10.42.10.131-7111-ca-org4.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/10.42.10.131-7111-ca-org4.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/10.42.10.131-7111-ca-org4.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/10.42.10.131-7111-ca-org4.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org4.insurance.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org4 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org4 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org4 --id.name org4admin --id.secret org4adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.131:7111 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/msp --csr.hosts peer0.org4.insurance.com --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.131:7111 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls --enrollment.profile tls --csr.hosts peer0.org4.insurance.com --csr.hosts 10.42.10.131 --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org4.insurance.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.insurance.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org4.insurance.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.insurance.com/tlsca/tlsca.org4.insurance.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org4.insurance.com/ca
  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/peers/peer0.org4.insurance.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org4.insurance.com/ca/ca.org4.insurance.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@10.42.10.131:7111 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.insurance.com/users/User1@org4.insurance.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org4.insurance.com/users/User1@org4.insurance.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org4admin:org4adminpw@10.42.10.131:7111 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.insurance.com/users/Admin@org4.insurance.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org4.insurance.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org4.insurance.com/users/Admin@org4.insurance.com/msp/config.yaml
}

function createOrg5() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org5.insurance.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org5.insurance.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@10.42.10.131:7112 --caname ca-org5 --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/10.42.10.131-7112-ca-org5.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/10.42.10.131-7112-ca-org5.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/10.42.10.131-7112-ca-org5.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/10.42.10.131-7112-ca-org5.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org5.insurance.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org5 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org5 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org5 --id.name org5admin --id.secret org5adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.131:7112 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/msp --csr.hosts peer0.org5.insurance.com --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.131:7112 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls --enrollment.profile tls --csr.hosts peer0.org5.insurance.com --csr.hosts 10.42.10.131 --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org5.insurance.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.insurance.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org5.insurance.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.insurance.com/tlsca/tlsca.org5.insurance.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org5.insurance.com/ca
  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/peers/peer0.org5.insurance.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org5.insurance.com/ca/ca.org5.insurance.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@10.42.10.131:7112 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.insurance.com/users/User1@org5.insurance.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org5.insurance.com/users/User1@org5.insurance.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org5admin:org5adminpw@10.42.10.131:7112 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.insurance.com/users/Admin@org5.insurance.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org5.insurance.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org5.insurance.com/users/Admin@org5.insurance.com/msp/config.yaml
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/insurance.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/insurance.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@10.42.10.131:7110 --caname ca-aaui --tls.certfiles ${PWD}/organizations/fabric-ca/aauiOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/10.42.10.131-7110-ca-aaui.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/10.42.10.131-7110-ca-aaui.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/10.42.10.131-7110-ca-aaui.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/10.42.10.131-7110-ca-aaui.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/insurance.com/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-aaui --id.name aaui --id.secret aauipw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/aauiOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-aaui --id.name aauiAdmin --id.secret aauiAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/aauiOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://aaui:aauipw@10.42.10.131:7110 --caname ca-aaui -M ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/msp --csr.hosts aaui.insurance.com --csr.hosts 10.42.10.131 --tls.certfiles ${PWD}/organizations/fabric-ca/aauiOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/insurance.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://aaui:aauipw@10.42.10.131:7110 --caname ca-aaui -M ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls --enrollment.profile tls --csr.hosts aaui.insurance.com --csr.hosts 10.42.10.131 --tls.certfiles ${PWD}/organizations/fabric-ca/aauiOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/msp/tlscacerts/tlsca.insurance.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/insurance.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/insurance.com/orderers/aaui.insurance.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/insurance.com/msp/tlscacerts/tlsca.insurance.com-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://aauiAdmin:aauiAdminpw@10.42.10.131:7110 --caname ca-aaui -M ${PWD}/organizations/ordererOrganizations/insurance.com/users/Admin@insurance.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/aauiOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/insurance.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/insurance.com/users/Admin@insurance.com/msp/config.yaml
}

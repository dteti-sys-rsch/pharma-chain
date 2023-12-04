#!/bin/bash

function createprudential() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/prudential.aaui.org/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/prudential.aaui.org/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11053 --caname ca-prudential --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11053-ca-prudential.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11053-ca-prudential.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11053-ca-prudential.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11053-ca-prudential.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/prudential.aaui.org/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-prudential --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-prudential --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-prudential --id.name prudentialadmin --id.secret prudentialadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11053 --caname ca-prudential -M ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/msp --csr.hosts peer0.prudential.aaui.org --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11053 --caname ca-prudential -M ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls --enrollment.profile tls --csr.hosts peer0.prudential.aaui.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/signcerts/* ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/keystore/* ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/prudential.aaui.org/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/prudential.aaui.org/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/prudential.aaui.org/tlsca
  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/prudential.aaui.org/tlsca/tlsca.prudential.aaui.org-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/prudential.aaui.org/ca
  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/msp/cacerts/* ${PWD}/organizations/peerOrganizations/prudential.aaui.org/ca/ca.prudential.aaui.org-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11053 --caname ca-prudential -M ${PWD}/organizations/peerOrganizations/prudential.aaui.org/users/User1@prudential.aaui.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/prudential.aaui.org/users/User1@prudential.aaui.org/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://prudentialadmin:prudentialadminpw@localhost:11053 --caname ca-prudential -M ${PWD}/organizations/peerOrganizations/prudential.aaui.org/users/Admin@prudential.aaui.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/prudential/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/prudential.aaui.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/prudential.aaui.org/users/Admin@prudential.aaui.org/msp/config.yaml
}

function createmanulife() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/manulife.aaui.org/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manulife.aaui.org/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-manulife --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-manulife.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-manulife.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-manulife.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-manulife.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/manulife.aaui.org/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-manulife --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-manulife --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-manulife --id.name manulifeadmin --id.secret manulifeadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-manulife -M ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/msp --csr.hosts peer0.manulife.aaui.org --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-manulife -M ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls --enrollment.profile tls --csr.hosts peer0.manulife.aaui.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/signcerts/* ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/keystore/* ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/manulife.aaui.org/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/manulife.aaui.org/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/manulife.aaui.org/tlsca
  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/manulife.aaui.org/tlsca/tlsca.manulife.aaui.org-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/manulife.aaui.org/ca
  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/msp/cacerts/* ${PWD}/organizations/peerOrganizations/manulife.aaui.org/ca/ca.manulife.aaui.org-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-manulife -M ${PWD}/organizations/peerOrganizations/manulife.aaui.org/users/User1@manulife.aaui.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/manulife.aaui.org/users/User1@manulife.aaui.org/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://manulifeadmin:manulifeadminpw@localhost:11054 --caname ca-manulife -M ${PWD}/organizations/peerOrganizations/manulife.aaui.org/users/Admin@manulife.aaui.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/manulife/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/manulife.aaui.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/manulife.aaui.org/users/Admin@manulife.aaui.org/msp/config.yaml
}

function createaaui() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/aaui.org

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/aaui.org

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12052 --caname ca-aaui --tls.certfiles ${PWD}/organizations/fabric-ca/aaui/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12052-ca-aaui.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12052-ca-aaui.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12052-ca-aaui.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12052-ca-aaui.pem
    OrganizationalUnitIdentifier: aaui' >${PWD}/organizations/ordererOrganizations/aaui.org/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-aaui --id.name aaui --id.secret aauipw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/aaui/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-aaui --id.name aauiAdmin --id.secret aauiAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/aaui/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://aaui:aauipw@localhost:12052 --caname ca-aaui -M ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp --csr.hosts orderer.aaui.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/aaui/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/aaui.org/msp/config.yaml ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://aaui:aauipw@localhost:12052 --caname ca-aaui -M ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls --enrollment.profile tls --csr.hosts orderer.aaui.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/aaui/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/keystore/* ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp/tlscacerts/tlsca.aaui.org-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/aaui.org/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/aaui.org/msp/tlscacerts/tlsca.aaui.org-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://aauiAdmin:aauiAdminpw@localhost:12052 --caname ca-aaui -M ${PWD}/organizations/ordererOrganizations/aaui.org/users/Admin@aaui.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/aaui/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/aaui.org/msp/config.yaml ${PWD}/organizations/ordererOrganizations/aaui.org/users/Admin@aaui.org/msp/config.yaml
}

#!/bin/bash

function createsardjito() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/sardjito.arsada.org/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/sardjito.arsada.org/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-sardjito --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-sardjito.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-sardjito.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-sardjito.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-sardjito.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/sardjito.arsada.org/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-sardjito --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-sardjito --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-sardjito --id.name sardjitoadmin --id.secret sardjitoadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-sardjito -M ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/msp --csr.hosts peer0.sardjito.arsada.org --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-sardjito -M ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls --enrollment.profile tls --csr.hosts peer0.sardjito.arsada.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/signcerts/* ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/keystore/* ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/tlsca
  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/tlsca/tlsca.sardjito.arsada.org-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/ca
  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/peers/peer0.sardjito.arsada.org/msp/cacerts/* ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/ca/ca.sardjito.arsada.org-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-sardjito -M ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/users/User1@sardjito.arsada.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/users/User1@sardjito.arsada.org/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://sardjitoadmin:sardjitoadminpw@localhost:11054 --caname ca-sardjito -M ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/users/Admin@sardjito.arsada.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/sardjito/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/sardjito.arsada.org/users/Admin@sardjito.arsada.org/msp/config.yaml
}

function createdharmais() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/dharmais.arsada.org/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/dharmais.arsada.org/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11052 --caname ca-dharmais --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11052-ca-dharmais.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11052-ca-dharmais.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11052-ca-dharmais.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11052-ca-dharmais.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/dharmais.arsada.org/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-dharmais --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-dharmais --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-dharmais --id.name dharmaisadmin --id.secret dharmaisadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11052 --caname ca-dharmais -M ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/msp --csr.hosts peer0.dharmais.arsada.org --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11052 --caname ca-dharmais -M ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls --enrollment.profile tls --csr.hosts peer0.dharmais.arsada.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/signcerts/* ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/keystore/* ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/tlsca
  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/tlsca/tlsca.dharmais.arsada.org-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/ca
  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/peers/peer0.dharmais.arsada.org/msp/cacerts/* ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/ca/ca.dharmais.arsada.org-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11052 --caname ca-dharmais -M ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/users/User1@dharmais.arsada.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/users/User1@dharmais.arsada.org/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://dharmaisadmin:dharmaisadminpw@localhost:11052 --caname ca-dharmais -M ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/users/Admin@dharmais.arsada.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/dharmais/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/msp/config.yaml ${PWD}/organizations/peerOrganizations/dharmais.arsada.org/users/Admin@dharmais.arsada.org/msp/config.yaml
}

function createarsada() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/arsada.org

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/arsada.org

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12051 --caname ca-arsada --tls.certfiles ${PWD}/organizations/fabric-ca/arsada/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12051-ca-arsada.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12051-ca-arsada.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12051-ca-arsada.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12051-ca-arsada.pem
    OrganizationalUnitIdentifier: arsada' >${PWD}/organizations/ordererOrganizations/arsada.org/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-arsada --id.name arsada --id.secret arsadapw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/arsada/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-arsada --id.name arsadaAdmin --id.secret arsadaAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/arsada/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://arsada:arsadapw@localhost:12051 --caname ca-arsada -M ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/msp --csr.hosts orderer.arsada.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/arsada/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/arsada.org/msp/config.yaml ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://arsada:arsadapw@localhost:12051 --caname ca-arsada -M ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls --enrollment.profile tls --csr.hosts orderer.arsada.org --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/arsada/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/keystore/* ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/msp/tlscacerts/tlsca.arsada.org-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/arsada.org/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/arsada.org/msp/tlscacerts/tlsca.arsada.org-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://arsadaAdmin:arsadaAdminpw@localhost:12051 --caname ca-arsada -M ${PWD}/organizations/ordererOrganizations/arsada.org/users/Admin@arsada.org/msp --tls.certfiles ${PWD}/organizations/fabric-ca/arsada/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/arsada.org/msp/config.yaml ${PWD}/organizations/ordererOrganizations/arsada.org/users/Admin@arsada.org/msp/config.yaml
}

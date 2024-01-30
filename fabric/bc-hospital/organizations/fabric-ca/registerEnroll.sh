#!/bin/bash

function createOrg1() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org1.hospital.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.hospital.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@10.42.10.132:7011 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/10.42.10.132-7011-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/10.42.10.132-7011-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/10.42.10.132-7011-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/10.42.10.132-7011-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org1.hospital.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.132:7011 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/msp --csr.hosts peer0.org1.hospital.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.132:7011 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls --enrollment.profile tls --csr.hosts peer0.org1.hospital.com --csr.hosts 10.42.10.132 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.hospital.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.hospital.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.hospital.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.hospital.com/tlsca/tlsca.org1.hospital.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.hospital.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/peers/peer0.org1.hospital.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.hospital.com/ca/ca.org1.hospital.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@10.42.10.132:7011 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.hospital.com/users/User1@org1.hospital.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.hospital.com/users/User1@org1.hospital.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@10.42.10.132:7011 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.hospital.com/users/Admin@org1.hospital.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.hospital.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.hospital.com/users/Admin@org1.hospital.com/msp/config.yaml
}

function createOrg2() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org2.hospital.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.hospital.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@10.42.10.132:7012 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/10.42.10.132-7012-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/10.42.10.132-7012-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/10.42.10.132-7012-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/10.42.10.132-7012-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org2.hospital.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.132:7012 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/msp --csr.hosts peer0.org2.hospital.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@10.42.10.132:7012 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls --enrollment.profile tls --csr.hosts peer0.org2.hospital.com --csr.hosts 10.42.10.132 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.hospital.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.hospital.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.hospital.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.hospital.com/tlsca/tlsca.org2.hospital.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.hospital.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/peers/peer0.org2.hospital.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.hospital.com/ca/ca.org2.hospital.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@10.42.10.132:7012 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.hospital.com/users/User1@org2.hospital.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.hospital.com/users/User1@org2.hospital.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@10.42.10.132:7012 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.hospital.com/users/Admin@org2.hospital.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.hospital.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.hospital.com/users/Admin@org2.hospital.com/msp/config.yaml
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/hospital.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/hospital.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@10.42.10.132:7010 --caname ca-arsada --tls.certfiles ${PWD}/organizations/fabric-ca/arsadaOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/10.42.10.132-7010-ca-arsada.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/10.42.10.132-7010-ca-arsada.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/10.42.10.132-7010-ca-arsada.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/10.42.10.132-7010-ca-arsada.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/hospital.com/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-arsada --id.name arsada --id.secret arsadapw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/arsadaOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-arsada --id.name arsadaAdmin --id.secret arsadaAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/arsadaOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://arsada:arsadapw@10.42.10.132:7010 --caname ca-arsada -M ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/msp --csr.hosts arsada.hospital.com --csr.hosts 10.42.10.132 --tls.certfiles ${PWD}/organizations/fabric-ca/arsadaOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/hospital.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://arsada:arsadapw@10.42.10.132:7010 --caname ca-arsada -M ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls --enrollment.profile tls --csr.hosts arsada.hospital.com --csr.hosts 10.42.10.132 --tls.certfiles ${PWD}/organizations/fabric-ca/arsadaOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/msp/tlscacerts/tlsca.hospital.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/hospital.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/hospital.com/orderers/arsada.hospital.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/hospital.com/msp/tlscacerts/tlsca.hospital.com-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://arsadaAdmin:arsadaAdminpw@10.42.10.132:7010 --caname ca-arsada -M ${PWD}/organizations/ordererOrganizations/hospital.com/users/Admin@hospital.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/arsadaOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/hospital.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/hospital.com/users/Admin@hospital.com/msp/config.yaml
}

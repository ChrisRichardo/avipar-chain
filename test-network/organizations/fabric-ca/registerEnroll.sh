#!/bin/bash

function createCirbus() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/cirbus.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/cirbus.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:6054 --caname ca-orgCirbus --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-orgCirbus.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-orgCirbus.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-orgCirbus.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-orgCirbus.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/cirbus.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgCirbus --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgCirbus --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgCirbus --id.name cirbusadmin --id.secret cirbusadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-orgCirbus -M "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/msp" --csr.hosts peer0.cirbus.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-orgCirbus -M "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls" --enrollment.profile tls --csr.hosts peer0.cirbus.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/cirbus.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/cirbus.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/cirbus.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/cirbus.example.com/tlsca/tlsca.cirbus.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/cirbus.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/cirbus.example.com/ca/ca.cirbus.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6054 --caname ca-orgCirbus -M "${PWD}/organizations/peerOrganizations/cirbus.example.com/users/User1@cirbus.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/cirbus.example.com/users/User1@cirbus.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://cirbusadmin:cirbusadminpw@localhost:6054 --caname ca-orgCirbus -M "${PWD}/organizations/peerOrganizations/cirbus.example.com/users/Admin@cirbus.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/cirbus/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cirbus.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/cirbus.example.com/users/Admin@cirbus.example.com/msp/config.yaml"
}

function createSoeing() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/soeing.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/soeing.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-orgSoeing --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-orgSoeing.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-orgSoeing.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-orgSoeing.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-orgSoeing.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/soeing.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgSoeing --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgSoeing --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgSoeing --id.name soeingadmin --id.secret soeingadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-orgSoeing -M "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/msp" --csr.hosts peer0.soeing.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-orgSoeing -M "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls" --enrollment.profile tls --csr.hosts peer0.soeing.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/soeing.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/soeing.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/soeing.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/soeing.example.com/tlsca/tlsca.soeing.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/soeing.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/soeing.example.com/ca/ca.soeing.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-orgSoeing -M "${PWD}/organizations/peerOrganizations/soeing.example.com/users/User1@soeing.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/soeing.example.com/users/User1@soeing.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://soeingadmin:soeingadminpw@localhost:7054 --caname ca-orgSoeing -M "${PWD}/organizations/peerOrganizations/soeing.example.com/users/Admin@soeing.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/soeing/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/soeing.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/soeing.example.com/users/Admin@soeing.example.com/msp/config.yaml"
}

function createNataAir() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/nataair.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/nataair.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-orgNataAir --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orgNataAir.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orgNataAir.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orgNataAir.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orgNataAir.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/nataair.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgNataAir --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgNataAir --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgNataAir --id.name nataairadmin --id.secret nataairadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-orgNataAir -M "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/msp" --csr.hosts peer0.nataair.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-orgNataAir -M "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls" --enrollment.profile tls --csr.hosts peer0.nataair.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/nataair.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/nataair.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/nataair.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/nataair.example.com/tlsca/tlsca.nataair.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/nataair.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/nataair.example.com/ca/ca.nataair.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-orgNataAir -M "${PWD}/organizations/peerOrganizations/nataair.example.com/users/User1@nataair.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/nataair.example.com/users/User1@nataair.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://nataairadmin:nataairadminpw@localhost:8054 --caname ca-orgNataAir -M "${PWD}/organizations/peerOrganizations/nataair.example.com/users/Admin@nataair.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/nataair/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/nataair.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/nataair.example.com/users/Admin@nataair.example.com/msp/config.yaml"
}

function createLycanAirSA() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/lycanairsa.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/lycanairsa.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-orgLycanAirSA --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orgLycanAirSA.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orgLycanAirSA.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orgLycanAirSA.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orgLycanAirSA.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgLycanAirSA --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgLycanAirSA --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgLycanAirSA --id.name lycanairsaadmin --id.secret lycanairsaadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-orgLycanAirSA -M "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/msp" --csr.hosts peer0.lycanairsa.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-orgLycanAirSA -M "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls" --enrollment.profile tls --csr.hosts peer0.lycanairsa.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/tlsca/tlsca.lycanairsa.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/ca/ca.lycanairsa.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-orgLycanAirSA -M "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/users/User1@lycanairsa.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/users/User1@lycanairsa.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://lycanairsaadmin:lycanairsaadminpw@localhost:10054 --caname ca-orgLycanAirSA -M "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/users/Admin@lycanairsa.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/lycanairsa/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/lycanairsa.example.com/users/Admin@lycanairsa.example.com/msp/config.yaml"
}

function createCengkarengAirwayEngineering() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/cengkarengairwayengineering.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:26054 --caname ca-orgCengkarengAirwayEngineering --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-26054-ca-orgCengkarengAirwayEngineering.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-26054-ca-orgCengkarengAirwayEngineering.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-26054-ca-orgCengkarengAirwayEngineering.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-26054-ca-orgCengkarengAirwayEngineering.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgCengkarengAirwayEngineering --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgCengkarengAirwayEngineering --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgCengkarengAirwayEngineering --id.name cengkarengairwayengineeringadmin --id.secret cengkarengairwayengineeringadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:26054 --caname ca-orgCengkarengAirwayEngineering -M "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/msp" --csr.hosts peer0.cengkarengairwayengineering.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:26054 --caname ca-orgCengkarengAirwayEngineering -M "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls" --enrollment.profile tls --csr.hosts peer0.cengkarengairwayengineering.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/tlsca/tlsca.cengkarengairwayengineering.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/ca/ca.cengkarengairwayengineering.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:26054 --caname ca-orgCengkarengAirwayEngineering -M "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/users/User1@cengkarengairwayengineering.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/users/User1@cengkarengairwayengineering.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://cengkarengairwayengineeringadmin:cengkarengairwayengineeringadminpw@localhost:26054 --caname ca-orgCengkarengAirwayEngineering -M "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/users/Admin@cengkarengairwayengineering.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/cengkarengairwayengineering/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/users/Admin@cengkarengairwayengineering.example.com/msp/config.yaml"
}

function createSemco() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/semco.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/semco.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:27054 --caname ca-orgSemco --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-27054-ca-orgSemco.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-27054-ca-orgSemco.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-27054-ca-orgSemco.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-27054-ca-orgSemco.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/semco.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgSemco --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgSemco --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgSemco --id.name semcoadmin --id.secret semcoadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:27054 --caname ca-orgSemco -M "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/msp" --csr.hosts peer0.semco.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/semco.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:27054 --caname ca-orgSemco -M "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls" --enrollment.profile tls --csr.hosts peer0.semco.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/semco.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/semco.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/semco.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/semco.example.com/tlsca/tlsca.semco.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/semco.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/semco.example.com/ca/ca.semco.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:27054 --caname ca-orgSemco -M "${PWD}/organizations/peerOrganizations/semco.example.com/users/User1@semco.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/semco.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/semco.example.com/users/User1@semco.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://semcoadmin:semcoadminpw@localhost:27054 --caname ca-orgSemco -M "${PWD}/organizations/peerOrganizations/semco.example.com/users/Admin@semco.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/semco/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/semco.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/semco.example.com/users/Admin@semco.example.com/msp/config.yaml"
}

function createAviparAirline() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/aviparairline.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/aviparairline.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:28054 --caname ca-orgAviparAirline --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-28054-ca-orgAviparAirline.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-28054-ca-orgAviparAirline.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-28054-ca-orgAviparAirline.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-28054-ca-orgAviparAirline.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/aviparairline.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgAviparAirline --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgAviparAirline --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgAviparAirline --id.name aviparairlineadmin --id.secret aviparairlineadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:28054 --caname ca-orgAviparAirline -M "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/msp" --csr.hosts peer0.aviparairline.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:28054 --caname ca-orgAviparAirline -M "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls" --enrollment.profile tls --csr.hosts peer0.aviparairline.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/aviparairline.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/aviparairline.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/aviparairline.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/aviparairline.example.com/tlsca/tlsca.aviparairline.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/aviparairline.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/aviparairline.example.com/ca/ca.aviparairline.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:28054 --caname ca-orgAviparAirline -M "${PWD}/organizations/peerOrganizations/aviparairline.example.com/users/User1@aviparairline.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/aviparairline.example.com/users/User1@aviparairline.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://aviparairlineadmin:aviparairlineadminpw@localhost:28054 --caname ca-orgAviparAirline -M "${PWD}/organizations/peerOrganizations/aviparairline.example.com/users/Admin@aviparairline.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/aviparairline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/aviparairline.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/aviparairline.example.com/users/Admin@aviparairline.example.com/msp/config.yaml"
}

function createPamulangAirway() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/pamulangairway.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/pamulangairway.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:29054 --caname ca-orgPamulangAirway --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-29054-ca-orgPamulangAirway.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-29054-ca-orgPamulangAirway.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-29054-ca-orgPamulangAirway.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-29054-ca-orgPamulangAirway.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgPamulangAirway --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgPamulangAirway --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgPamulangAirway --id.name pamulangairwayadmin --id.secret pamulangairwayadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:29054 --caname ca-orgPamulangAirway -M "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/msp" --csr.hosts peer0.pamulangairway.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:29054 --caname ca-orgPamulangAirway -M "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls" --enrollment.profile tls --csr.hosts peer0.pamulangairway.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/tlsca/tlsca.pamulangairway.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/ca/ca.pamulangairway.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:29054 --caname ca-orgPamulangAirway -M "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/users/User1@pamulangairway.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/users/User1@pamulangairway.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://pamulangairwayadmin:pamulangairwayadminpw@localhost:29054 --caname ca-orgPamulangAirway -M "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/users/Admin@pamulangairway.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pamulangairway/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pamulangairway.example.com/users/Admin@pamulangairway.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}

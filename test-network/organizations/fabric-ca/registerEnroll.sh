#!/bin/bash

function createManufacturer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:6054 --caname ca-orgManufacturer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgManufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgManufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgManufacturer --id.name manufactureradmin --id.secret manufactureradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-orgManufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp" --csr.hosts peer0.manufacturer.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-orgManufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls" --enrollment.profile tls --csr.hosts peer0.manufacturer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/ca/ca.manufacturer.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6054 --caname ca-orgManufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:6054 --caname ca-orgManufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp/config.yaml"
}

function createVendor() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/vendor.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/vendor.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-orgVendor --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-vendor.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-vendor.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-vendor.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-vendor.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/vendor.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgVendor --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgVendor --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgVendor --id.name vendoradmin --id.secret vendoradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-orgVendor -M "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/msp" --csr.hosts peer0.vendor.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-orgVendor -M "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls" --enrollment.profile tls --csr.hosts peer0.vendor.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/vendor.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/vendor.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/vendor.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/vendor.example.com/tlsca/tlsca.vendor.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/vendor.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/vendor.example.com/ca/ca.vendor.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-orgVendor -M "${PWD}/organizations/peerOrganizations/vendor.example.com/users/User1@vendor.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/vendor.example.com/users/User1@vendor.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://vendoradmin:vendoradminpw@localhost:7054 --caname ca-orgVendor -M "${PWD}/organizations/peerOrganizations/vendor.example.com/users/Admin@vendor.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/vendor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/vendor.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/vendor.example.com/users/Admin@vendor.example.com/msp/config.yaml"
}

function createAirline() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/airline.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/airline.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-orgAirline --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airline.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airline.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airline.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airline.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/airline.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-orgAirline --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-orgAirline --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-orgAirline --id.name airlineadmin --id.secret airlineadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-orgAirline -M "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/msp" --csr.hosts peer0.airline.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airline.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-orgAirline -M "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls" --enrollment.profile tls --csr.hosts peer0.airline.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/airline.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/airline.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/airline.example.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/airline.example.com/tlsca/tlsca.airline.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/airline.example.com/ca"
  cp "${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/airline.example.com/ca/ca.airline.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-orgAirline -M "${PWD}/organizations/peerOrganizations/airline.example.com/users/User1@airline.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airline.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/airline.example.com/users/User1@airline.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://airlineadmin:airlineadminpw@localhost:8054 --caname ca-orgAirline -M "${PWD}/organizations/peerOrganizations/airline.example.com/users/Admin@airline.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/airline/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airline.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/airline.example.com/users/Admin@airline.example.com/msp/config.yaml"
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

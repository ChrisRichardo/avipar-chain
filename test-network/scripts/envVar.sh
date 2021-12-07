#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_MANUFACTURER_CA=${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt
export PEER0_VENDOR_CA=${PWD}/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/ca.crt
export PEER0_AIRLINE_CA=${PWD}/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/ca.crt
export PEER0_MRO_CA=${PWD}/organizations/peerOrganizations/mro.example.com/peers/peer0.mro.example.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ "$USING_ORG" == "Manufacturer" ]; then
    export CORE_PEER_LOCALMSPID="ManufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANUFACTURER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:6051
  elif [ "$USING_ORG" == "Vendor" ]; then
    export CORE_PEER_LOCALMSPID="VendorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_VENDOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/vendor.example.com/users/Admin@vendor.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ "$USING_ORG" == "Airline" ]; then
    export CORE_PEER_LOCALMSPID="AirlineMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_AIRLINE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/airline.example.com/users/Admin@airline.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
  elif [ "$USING_ORG" == "MRO" ]; then
    export CORE_PEER_LOCALMSPID="MROMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MRO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mro.example.com/users/Admin@mro.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ "$USING_ORG" == "Manufacturer" ]; then
    export CORE_PEER_ADDRESS=peer0.manufacturer.example.com:6051
  elif [ "$USING_ORG" == "Vendor" ]; then
    export CORE_PEER_ADDRESS=peer0.vendor.example.com:7051
  elif [ "$USING_ORG" == "Airline" ]; then
    export CORE_PEER_ADDRESS=peer0.airline.example.com:8051
  elif [ "$USING_ORG" == "MRO" ]; then
    export CORE_PEER_ADDRESS=peer0.mro.example.com:10051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    local ORG_UPPER=""
    infoln "$USING_ORG"
    if [ "$1" == "Manufacturer" ]; then
      ORG_UPPER="MANUFACTURER"
    elif [ "$1" == "Vendor" ]; then
      ORG_UPPER="VENDOR"
    elif [ "$1" == "Airline" ]; then
      ORG_UPPER="AIRLINE"
    elif [ "$1" == "MRO" ]; then
      ORG_UPPER="MRO"
    fi
    CA=PEER0_${ORG_UPPER}_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    infoln "${!CA}"
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

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
export PEER0_CIRBUS_CA=${PWD}/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/ca.crt
export PEER0_SOEING_CA=${PWD}/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/ca.crt
export PEER0_NATAAIR_CA=${PWD}/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/ca.crt
export PEER0_LYCANAIRSA_CA=${PWD}/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/ca.crt
export PEER0_CENGKARENGAIRWAYENGINEERING_CA=${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/ca.crt
export PEER0_SEMCO_CA=${PWD}/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/ca.crt
export PEER0_AVIPARAIRLINE_CA=${PWD}/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/ca.crt
export PEER0_PAMULANGAIRWAY_CA=${PWD}/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/ca.crt
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
  if [ "$USING_ORG" == "Cirbus" ]; then
    export CORE_PEER_LOCALMSPID="CirbusMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CIRBUS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/cirbus.example.com/users/Admin@cirbus.example.com/msp
    export CORE_PEER_ADDRESS=localhost:6051
  elif [ "$USING_ORG" == "Soeing" ]; then
    export CORE_PEER_LOCALMSPID="SoeingMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_SOEING_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/soeing.example.com/users/Admin@soeing.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ "$USING_ORG" == "NataAir" ]; then
    export CORE_PEER_LOCALMSPID="NataAirMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_NATAAIR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/nataair.example.com/users/Admin@nataair.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
  elif [ "$USING_ORG" == "LycanAirSA" ]; then
    export CORE_PEER_LOCALMSPID="LycanAirSAMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LYCANAIRSA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/lycanairsa.example.com/users/Admin@lycanairsa.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
  elif [ "$USING_ORG" == "CengkarengAirwayEngineering" ]; then
    export CORE_PEER_LOCALMSPID="CengkarengAirwayEngineeringMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CENGKARENGAIRWAYENGINEERING_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/cengkarengairwayengineering.example.com/users/Admin@cengkarengairwayengineering.example.com/msp
    export CORE_PEER_ADDRESS=localhost:26051
  elif [ "$USING_ORG" == "Semco" ]; then
    export CORE_PEER_LOCALMSPID="SemcoMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_SEMCO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/semco.example.com/users/Admin@semco.example.com/msp
    export CORE_PEER_ADDRESS=localhost:27051
  elif [ "$USING_ORG" == "AviparAirline" ]; then
    export CORE_PEER_LOCALMSPID="AviparAirlineMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_AVIPARAIRLINE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/aviparairline.example.com/users/Admin@aviparairline.example.com/msp
    export CORE_PEER_ADDRESS=localhost:28051
  elif [ "$USING_ORG" == "PamulangAirway" ]; then
    export CORE_PEER_LOCALMSPID="PamulangAirwayMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PAMULANGAIRWAY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/pamulangairway.example.com/users/Admin@pamulangairway.example.com/msp
    export CORE_PEER_ADDRESS=localhost:29051
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
  if [ "$USING_ORG" == "Cirbus" ]; then
    export CORE_PEER_ADDRESS=peer0.cirbus.example.com:6051
  elif [ "$USING_ORG" == "Soeing" ]; then
    export CORE_PEER_ADDRESS=peer0.soeing.example.com:7051
  elif [ "$USING_ORG" == "NataAir" ]; then
    export CORE_PEER_ADDRESS=peer0.nataair.example.com:8051
  elif [ "$USING_ORG" == "LycanAirSA" ]; then
    export CORE_PEER_ADDRESS=peer0.lycanairsa.example.com:10051
  elif [ "$USING_ORG" == "CengkarengAirwayEngineering" ]; then
    export CORE_PEER_ADDRESS=peer0.cengkarengairwayengineering.example.com:26051
  elif [ "$USING_ORG" == "Semco" ]; then
    export CORE_PEER_ADDRESS=peer0.semco.example.com:27051
  elif [ "$USING_ORG" == "AviparAirline" ]; then
    export CORE_PEER_ADDRESS=peer0.aviparairline.example.com:28051
  elif [ "$USING_ORG" == "PamulangAirway" ]; then
    export CORE_PEER_ADDRESS=peer0.pamulangairway.example.com:29051
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
    if [ "$1" == "Cirbus" ]; then
      ORG_UPPER="CIRBUS"
    elif [ "$1" == "Soeing" ]; then
      ORG_UPPER="SOEING"
    elif [ "$1" == "NataAir" ]; then
      ORG_UPPER="NATAAIR"
    elif [ "$1" == "LycanAirSA" ]; then
      ORG_UPPER="LYCANAIRSA"
    elif [ "$1" == "CengkarengAirwayEngineering" ]; then
      ORG_UPPER="CENGKARENGAIRWAYENGINEERING"
    elif [ "$1" == "Semco" ]; then
      ORG_UPPER="SEMCO"
    elif [ "$1" == "AviparAirline" ]; then
      ORG_UPPER="AVIPARAIRLINE"
    elif [ "$1" == "PamulangAirway" ]; then
      ORG_UPPER="PAMULANGAIRWAY"

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

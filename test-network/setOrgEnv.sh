#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using Org1
ORG=${1:-Manufacturer}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
PEER0_MANUFACTURER_CA=${DIR}/test-network/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt
PEER0_VENDOR_CA=${DIR}/test-network/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/ca.crt
PEER0_AIRLINE_CA=${DIR}/test-network/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/ca.crt
PEER0_MRO_CA=${DIR}/test-network/organizations/peerOrganizations/mro.example.com/peers/peer0.mro.example.com/tls/ca.crt


if [ ${ORG,,} == "manufacturer"]; then

   CORE_PEER_LOCALMSPID=ManufacturerMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp
   CORE_PEER_ADDRESS=localhost:6051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt

elif [ ${ORG,,} == "vendor"]; then

   CORE_PEER_LOCALMSPID=VendorMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/vendor.example.com/users/Admin@vendor.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/vendor.example.com/peers/peer0.vendor.example.com/tls/ca.crt

elif [ ${ORG,,} == "airline"]; then

   CORE_PEER_LOCALMSPID=AirlineMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/airline.example.com/users/Admin@airline.example.com/msp
   CORE_PEER_ADDRESS=localhost:8051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/airline.example.com/peers/peer0.airline.example.com/tls/ca.crt

elif [ ${ORG,,} == "mro"]; then

   CORE_PEER_LOCALMSPID=MROMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/mro.example.com/users/Admin@mro.example.com/msp
   CORE_PEER_ADDRESS=localhost:10051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/mro.example.com/peers/peer0.mro.example.com/tls/ca.crt

else
   echo "Unknown \"$ORG\", please choose Org1/Digibank or Org2/Magnetocorp"
   echo "For example to get the environment variables to set upa Org2 shell environment run:  ./setOrgEnv.sh Org2"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh Org2 | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_MANUFACTURER_CA=${PEER0_MANUFACTURER_CA}"
echo "PEER0_VENDOR_CA=${PEER0_VENDOR_CA}"
echo "PEER0_AIRLINE_CA=${PEER0_AIRLINE_CA}"
echo "PEER0_MRO_CA=${PEER0_MRO_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
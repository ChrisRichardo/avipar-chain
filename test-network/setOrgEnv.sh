#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using Org1
ORG=${1:-Cirbus}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
PEER0_CIRBUS_CA=${DIR}/test-network/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/ca.crt
PEER0_SOEING_CA=${DIR}/test-network/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/ca.crt
PEER0_NATAAIR_CA=${DIR}/test-network/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/ca.crt
PEER0_LYCANAIRSA_CA=${DIR}/test-network/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/ca.crt
PEER0_CENGKARENGAIRWAYENGINEERING_CA=${DIR}/test-network/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/ca.crt
PEER0_SEMCO_CA=${DIR}/test-network/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/ca.crt
PEER0_AVIPARAIRLINE_CA=${DIR}/test-network/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/ca.crt
PEER0_PAMULANGAIRWAY_CA=${DIR}/test-network/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/c


if [ ${ORG,,} == "cirbus"]; then

   CORE_PEER_LOCALMSPID=CirbusMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/cirbus.example.com/users/Admin@cirbus.example.com/msp
   CORE_PEER_ADDRESS=localhost:6051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/cirbus.example.com/peers/peer0.cirbus.example.com/tls/ca.crt

elif [ ${ORG,,} == "soeing"]; then

   CORE_PEER_LOCALMSPID=SoeingMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/soeing.example.com/users/Admin@soeing.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/soeing.example.com/peers/peer0.soeing.example.com/tls/ca.crt

elif [ ${ORG,,} == "nataair"]; then

   CORE_PEER_LOCALMSPID=NataAirMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/nataair.example.com/users/Admin@nataair.example.com/msp
   CORE_PEER_ADDRESS=localhost:8051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/nataair.example.com/peers/peer0.nataair.example.com/tls/ca.crt

elif [ ${ORG,,} == "lycanairsa"]; then

   CORE_PEER_LOCALMSPID=LycanAirSAMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/lycanairsa.example.com/users/Admin@lycanairsa.example.com/msp
   CORE_PEER_ADDRESS=localhost:10051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/lycanairsa.example.com/peers/peer0.lycanairsa.example.com/tls/ca.crt

elif [ ${ORG,,} == "cengkarengairwayengineering"]; then

   CORE_PEER_LOCALMSPID=CengkarengAirwayEngineeringMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/cengkarengairwayengineering.example.com/users/Admin@cengkarengairwayengineering.example.com/msp
   CORE_PEER_ADDRESS=localhost:26051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/cengkarengairwayengineering.example.com/peers/peer0.cengkarengairwayengineering.example.com/tls/ca.crt

elif [ ${ORG,,} == "semco"]; then

   CORE_PEER_LOCALMSPID=SemcoMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/semco.example.com/users/Admin@semco.example.com/msp
   CORE_PEER_ADDRESS=localhost:27051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/semco.example.com/peers/peer0.semco.example.com/tls/ca.crt

elif [ ${ORG,,} == "aviparairline"]; then

   CORE_PEER_LOCALMSPID=AviparAirlineMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/aviparairline.example.com/users/Admin@aviparairline.example.com/msp
   CORE_PEER_ADDRESS=localhost:28051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/aviparairline.example.com/peers/peer0.aviparairline.example.com/tls/ca.crt

elif [ ${ORG,,} == "pamulangairway"]; then

   CORE_PEER_LOCALMSPID=PamulangAirwayMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/pamulangairway.example.com/users/Admin@pamulangairway.example.com/msp
   CORE_PEER_ADDRESS=localhost:29051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/pamulangairway.example.com/peers/peer0.pamulangairway.example.com/tls/ca.crt

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
echo "PEER0_CIRBUS_CA=${PEER0_CIRBUS_CA}"
echo "PEER0_SOEING_CA=${PEER0_SOEING_CA}"
echo "PEER0_NATAAIR_CA=${PEER0_NATAAIR_CA}"
echo "PEER0_LYCANAIRSA_CA=${PEER0_LYCANAIRSA_CA}"
echo "PEER0_CENGKARENGAIRWAYENGINEERING_CA=${PEER0_CENGKARENGAIRWAYENGINEERING_CA}"
echo "PEER0_SEMCO_CA=${PEER0_SEMCO_CA}"
echo "PEER0_AVIPARAIRLINE_CA=${PEER0_AVIPARAIRLINE_CA}"
echo "PEER0_PAMULANGAIRWAY_CA=${PEER0_PAMULANGAIRWAY_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
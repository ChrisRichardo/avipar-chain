#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# import utils
. scripts/envVar.sh
. scripts/configUpdate.sh


# NOTE: this must be run in a CLI container since it requires jq and configtxlator 
createAnchorPeerUpdate() {
  infoln "Fetching channel config for channel $CHANNEL_NAME"
  fetchChannelConfig $ORG $CHANNEL_NAME ${CORE_PEER_LOCALMSPID}config.json

  infoln "Generating anchor peer update transaction for Org${ORG} on channel $CHANNEL_NAME"

  if [ "$ORG" == "Cirbus" ]; then
    HOST="peer0.cirbus.example.com"
    PORT=6051
  elif [ "$ORG" == "Soeing" ]; then
    HOST="peer0.soeing.example.com"
    PORT=7051
  elif [ "$ORG" == "NataAir" ]; then
    HOST="peer0.nataair.example.com"
    PORT=8051
  elif [ "$ORG" == "LycanAirSA" ]; then
    HOST="peer0.lycanairsa.example.com"
    PORT=10051
  elif [ "$ORG" == "CengkarengAirwayEngineering" ]; then
    HOST="peer0.cengkarengairwayengineering.example.com"
    PORT=26051
  elif [ "$ORG" == "Semco" ]; then
    HOST="peer0.semco.example.com"
    PORT=27051
  elif [ "$ORG" == "AviparAirline" ]; then
    HOST="peer0.aviparairline.example.com"
    PORT=28051
  elif [ "$ORG" == "PamulangAirway" ]; then
    HOST="peer0.pamulangairway.example.com"
    PORT=29051
  else
    errorln "Org${ORG} unknown"
  fi

  set -x
  # Modify the configuration to append the anchor peer 
  jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json > ${CORE_PEER_LOCALMSPID}modified_config.json
  { set +x; } 2>/dev/null

  # Compute a config update, based on the differences between 
  # {orgmsp}config.json and {orgmsp}modified_config.json, write
  # it as a transaction to {orgmsp}anchors.tx
  createConfigUpdate ${CHANNEL_NAME} ${CORE_PEER_LOCALMSPID}config.json ${CORE_PEER_LOCALMSPID}modified_config.json ${CORE_PEER_LOCALMSPID}anchors.tx
}

updateAnchorPeer() {
  peer channel update -o orderer.example.com:6050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile "$ORDERER_CA" >&log.txt
  res=$?
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peer set for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
}

ORG=$1
CHANNEL_NAME=$2
setGlobalsCLI $ORG

createAnchorPeerUpdate 

updateAnchorPeer 

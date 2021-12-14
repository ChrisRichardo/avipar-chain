#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

createChannelGenesisBlock() {
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	set -x
	configtxgen -profile EightOrgsApplicationGenesis -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
	setGlobals Cirbus
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		#kalo error ganti ke osnadmin channel join --channelID $CHANNEL_NAME --config-block ./channel-artifacts/${CHANNEL_NAME}.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >&log.txt
		osnadmin channel join --channelID $CHANNEL_NAME --config-block ./channel-artifacts/${CHANNEL_NAME}.block -o localhost:6053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

# joinChannel ORG
joinChannel() {
  FABRIC_CFG_PATH=$PWD/../config/
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b $BLOCKFILE >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
  ORG=$1
  docker exec cli ./scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channel genesis block
infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
createChannelGenesisBlock

FABRIC_CFG_PATH=$PWD/../config/
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

## Join all the peers to the channel
infoln "Joining Cirbus peer to the channel..."
joinChannel Cirbus
infoln "Joining Soeing peer to the channel..."
joinChannel Soeing
infoln "Joining NataAir peer to the channel..."
joinChannel NataAir
infoln "Joining LycanAirSA peer to the channel..."
joinChannel LycanAirSA
infoln "Joining CengkarengAirwayEngineering peer to the channel..."
joinChannel CengkarengAirwayEngineering
infoln "Joining Semco peer to the channel..."
joinChannel Semco
infoln "Joining AviparAirline peer to the channel..."
joinChannel AviparAirline
infoln "Joining PamulangAirway peer to the channel..."
joinChannel PamulangAirway

## Set the anchor peers for each org in the channel
infoln "Setting anchor peer for Cirbus..."
setAnchorPeer Cirbus
infoln "Setting anchor peer for Soeing..."
setAnchorPeer Soeing
infoln "Setting anchor peer for NataAir..."
setAnchorPeer NataAir
infoln "Setting anchor peer for LycanAirSA..."
setAnchorPeer LycanAirSA
infoln "Setting anchor peer for CengkarengAirwayEngineering..."
setAnchorPeer CengkarengAirwayEngineering
infoln "Setting anchor peer for Semco..."
setAnchorPeer Semco
infoln "Setting anchor peer for AviparAirline..."
setAnchorPeer AviparAirline
infoln "Setting anchor peer for PamulangAirway..."
setAnchorPeer PamulangAirway

successln "Channel '$CHANNEL_NAME' joined"

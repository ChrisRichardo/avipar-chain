#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
CC_SRC_LANGUAGE=${1:-"go"}
CC_SRC_LANGUAGE=`echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:]`
CC_CG="../chaincode/avipar-chain/go/collection_config.json"

if [ "$CC_SRC_LANGUAGE" = "go" -o "$CC_SRC_LANGUAGE" = "golang" ] ; then
	CC_SRC_PATH="../chaincode/avipar-chain/go/"
else
	echo The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script
	echo Supported chaincode languages are: go, java, javascript, and typescript
	exit 1
fi

# clean out any old identites in the wallets
rm -rf javascript/orgCirbus-wallet/*
rm -rf javascript/orgSoeing-wallet/*
rm -rf javascript/orgNataAir-wallet/*
rm -rf javascript/orgLycanAirSA-wallet/*
rm -rf javascript/orgCengkarengAirwayEngineering-wallet/*
rm -rf javascript/orgSemco-wallet/*
rm -rf javascript/orgAviparAirline-wallet/*
rm -rf javascript/orgPamulangAirway-wallet/*


# launch network; create channel and join peer to channel
pushd ../test-network
./network.sh down
./network.sh up createChannel -ca -s couchdb
./network.sh deployCC -ccn fabcar -ccv 1 -cci initLedger -ccl ${CC_SRC_LANGUAGE} -ccp ${CC_SRC_PATH} -cccg ${CC_CG}
popd

cat <<EOF

Total setup execution time : $(($(date +%s) - starttime)) secs ...

Next, use the Avipar applications to interact with the deployed Avipar contract.
The Avipar applications are available in multiple programming languages.
Follow the instructions for the programming language of your choice:

JavaScript:

  Start by changing into the "javascript" directory:
    cd javascript

  Next, install all required packages:
    npm install

  Finally, execute the api server initiate library:
    node apiserver

EOF

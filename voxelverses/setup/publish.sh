#!/bin/bash

# check dependencies are available.
for i in jq curl sui; do
  if ! command -V ${i} 2>/dev/null; then
    echo "${i} is not installed"
    exit 1
  fi
done

NETWORK=http://localhost:9000
FAUCET=https://localhost:9000/gas

MOVE_PACKAGE_PATH=../

if [ $# -ne 0 ]; then
  if [ $1 = "testnet" ]; then
    NETWORK="https://rpc.testnet.sui.io:443"
    FAUCET="https://faucet.testnet.sui.io/gas"
  fi
  if [ $1 = "devnet" ]; then
    NETWORK="https://rpc.devnet.sui.io:443"
    FAUCET="https://faucet.devnet.sui.io/gas"
  fi
fi

# echo "- Admin Address is: ${ADMIN_ADDRESS}"

# import_address=$(sui keytool import "$ADMIN_PHRASE" ed25519)

# switch_res=$(sui client switch --address ${ADMIN_ADDRESS})

switch_env=$(sui client switch --env "testnet")

publish_res=$(sui client publish --skip-fetch-latest-git-deps --gas-budget 2000000000 --json ${MOVE_PACKAGE_PATH})

echo ${publish_res} >.publish.res.json

# Check if the command succeeded (exit status 0)
if [[ "$publish_res" =~ "error" ]]; then
  # If yes, print the error message and exit the script
  echo "Error during move contract publishing.  Details : $publish_res"
  exit 1
fi

publishedObjs=$(echo "$publish_res" | jq -r '.objectChanges[] | select(.type == "published")')

PACKAGE_ID=$(echo "$publishedObjs" | jq -r '.packageId')

newObjs=$(echo "$publish_res" | jq -r '.objectChanges[] | select(.type == "created")')

HOUSE_ADMIN_CAP=$(echo "$newObjs" | jq -r 'select (.objectType | contains("game_token::GameTokenStore")).objectId')

suffix=""
if [ $# -eq 0 ]; then
  suffix=".localnet"
fi

cat >.env<<-API_ENV
SUI_NETWORK=$NETWORK
PACKAGE_ADDRESS=$PACKAGE_ID
HOUSE_ADMIN_CAP=$HOUSE_ADMIN_CAP
API_ENV

echo "Contract Deployment finished!"

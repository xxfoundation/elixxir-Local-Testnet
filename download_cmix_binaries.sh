#!/usr/bin/env bash

set -x

# Set up the URL for downloading the binaries
PRIVATEGRITY_REPOS="https://gitlab.com/api/v4/projects/elixxir%2F"
MASTER_URL_FRAG="jobs/artifacts/master/raw/release"
DISPATCH_URL_FRAG="jobs/artifacts/dispatch/raw/release"

# Platform variables
LINUX_BIN=".linux64?job=build"
MAC_BIN=".darwin64?job=build"

# Get URLs for artifacts from all relevant repos
UDB_URL="${PRIVATEGRITY_REPOS}user-discovery-bot/$DISPATCH_URL_FRAG/udb$MAC_BIN"
SERVER_URL="${PRIVATEGRITY_REPOS}server/$DISPATCH_URL_FRAG/server$MAC_BIN"
GW_URL="${PRIVATEGRITY_REPOS}gateway/$DISPATCH_URL_FRAG/gateway$MAC_BIN"
PERMISSIONING_URL="${PRIVATEGRITY_REPOS}registration/$MASTER_URL_FRAG/registration$MAC_BIN"

# Set up the gitlab access token
PATKEY="rBxQ6BvKP-eFxxeM3Ugm"

# Make the binaries directory
download_path="$(pwd)/binaries"
mkdir -p "$download_path"

# Silently download the UDB binary to the provisioning directory
curl -s -f -L -H "PRIVATE-TOKEN: $PATKEY" -o "$download_path/udb.binary" ${UDB_URL}

# Silently download the Server binary to the provisioning directory
curl -s -f -L -H "PRIVATE-TOKEN: $PATKEY" -o "$download_path/server.binary" ${SERVER_URL}

# Silently download the Gateway binary to the provisioning directory
curl -s -f -L -H "PRIVATE-TOKEN: $PATKEY" -o "$download_path/gateway.binary" ${GW_URL}

# Silently download the permissioning binary to the provisioning directory
curl -s -f -L -H "PRIVATE-TOKEN: $PATKEY" -o "$download_path/permissioning.binary" ${PERMISSIONING_URL}

file "$download_path"/*

echo "If you see HTML or anything but linux binaries above, something is messed up!"

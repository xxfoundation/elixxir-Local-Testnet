#!/usr/bin/env bash

set -x


# Get platform parameter
if [[ $1 == "l" ]] ||[[ $1 == "linux" ]] || [[ -z $1 ]]; then
    BIN=".linux64?job=build"
    echo "Platform set to Linux"
elif [[ $1 == "m" ]] || [[ $1 == "mac" ]]; then
    BIN=".darwin64?job=build"
    echo "Platform set to Mac"
else
    echo "Invalid platform argument: $1"
    exit 0
fi

if [[ $2 == "m" ]] ||[[ $2 == "master" ]] || [[ -z $2 ]]; then
    URL_FRAG="jobs/artifacts/master/raw/release"
    echo "Downloading Master Binaries"
elif [[ $2 == "r" ]] || [[ $2 == "release" ]]; then
    URL_FRAG="jobs/artifacts/release/raw/release"
    echo "Downloading Release Binaries"
else
    echo "Invalid branch argument: $2"
    exit 0
fi

# Set up the URL for downloading the binaries
PRIVATEGRITY_REPOS="https://gitlab.com/api/v4/projects/elixxir%2F"


# Get URLs for artifacts from all relevant repos
UDB_URL="${PRIVATEGRITY_REPOS}user-discovery-bot/$URL_FRAG/udb$BIN"
SERVER_URL="${PRIVATEGRITY_REPOS}server/$URL_FRAG/server$BIN"
GW_URL="${PRIVATEGRITY_REPOS}gateway/$URL_FRAG/gateway$BIN"
PERMISSIONING_URL="${PRIVATEGRITY_REPOS}registration/$URL_FRAG/registration$BIN"

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
curl -s -f -L -H "PRIVATE-TOKEN: $PATKEY" -o "$download_path/registration.binary" ${PERMISSIONING_URL}

# Make binaries executable
chmod +x "$download_path"/*.binary

file "$download_path"/*

echo "If you see HTML or anything but linux binaries above, something is messed up!"

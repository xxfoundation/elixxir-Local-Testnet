#!/usr/bin/env bash

BIN_PATH="$(pwd)/binaries"
CONFIG_PATH="$(pwd)/configurations"

"$BIN_PATH"/permissioning.binary -c "$CONFIG_PATH/permissioning.yaml" \
-k "$CONFIG_PATH/dsa.json" &

"$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-1.yaml" -i 0 \
--keyPairOverride "$CONFIG_PATH/dsa.json" &
"$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-2.yaml" -i 1 \
--keyPairOverride "$CONFIG_PATH/dsa.json" &
"$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-3.yaml" -i 2 \
--keyPairOverride "$CONFIG_PATH/dsa.json" &

"$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-1.yaml" -i 0 &
"$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-2.yaml" -i 1 &
"$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-3.yaml" -i 2 &

"$BIN_PATH"/udb.binary --config "$CONFIG_PATH/udb.yaml" \
-n "$CONFIG_PATH/ndf.json"

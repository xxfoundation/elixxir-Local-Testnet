#!/usr/bin/env bash

noTls=""

# Get parameter on which binaries to NOT run
for arg in "$@"
do
    case ${arg} in
        "p" | "permissioning")
            runPermissioning="false"
            ;;
        "s" | "server")
            runServer="false"
            ;;
        "g" | "gateway")
            runGateway="false"
            ;;
        "u" | "udb")
            runUDB="false"
            ;;
        "noTLS" | "notls")
            noTls="--noTLS"
    esac
done

BIN_PATH="$(pwd)/binaries"
CONFIG_PATH="$(pwd)/configurations"

if [[ -z ${runPermissioning} ]]; then
    "$BIN_PATH"/permissioning.binary -c "$CONFIG_PATH/permissioning.yaml" \
                ${noTls} -v --InsecureClientRegCode "AAAA" &
    echo "Permissioning: " $!
else
    echo "Skipping execution of permissioning binary."
fi

if [[ -z ${runServer} ]]; then
    "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-1.yaml" -i 0 \
     --disablePermissioning --metricsWhitespace ${noTls} &
    echo "Server 1: " $!
    "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-2.yaml" -i 1 \
    --disablePermissioning --metricsWhitespace ${noTls} &
     echo "Server 2: " $!
    "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-3.yaml" -i 2 \
    --disablePermissioning --metricsWhitespace ${noTls} &
    echo "Server 3: " $!
else
    echo "Skipping execution of server binary."
fi

if [[ -z ${runGateway} ]]; then
    "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-1.yaml" -i 0 -v --disablePermissioning  ${noTls} &
    echo "Gateway 1: " $!
    "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-2.yaml" -i 1 -v --disablePermissioning  ${noTls} &
    echo "Gateway 2: " $!
    "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-3.yaml" -i 2 -v --disablePermissioning  ${noTls} &
    echo "Gateway 3: " $!
else
    echo "Skipping execution of gateway binary."
fi

if [[ -z ${runUDB} ]]; then
    "$BIN_PATH"/udb.binary --config "$CONFIG_PATH/udb.yaml" ${noTls} -v &
    echo "UDB: " $!

else
    echo "Skipping execution of UDB binary."
fi

# Pipe child PIDs into file
jobs -p > "pids.tmp"

finish() {
    # Read in and kill all child PIDs
    for job in $(cat pids.tmp)
    do
        echo "KILLING $job"
        kill "$job" || true
    done
}

# Execute finish function on exit
trap finish EXIT

# Wait until user input to exit
read -p 'Press enter to exit...'

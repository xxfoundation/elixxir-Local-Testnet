#!/usr/bin/env bash

# Clear out the previous run's logs
rm *.log

# Globals
noTls=""
disablePermissioning=""
nodes=$(ls -1q configurations/servers/server-*.yml | wc -l | xargs)

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
            ;;
        "disablePermissioning")
            disablePermissioning="--disablePermissioning"
            ;;
    esac
done

BIN_PATH="$(pwd)/binaries"
CONFIG_PATH="$(pwd)/configurations"

if [[ -z ${runPermissioning} ]]; then
    "$BIN_PATH"/registration.binary -c "$CONFIG_PATH/registration.yml" \
                ${noTls} -v ${disablePermissioning} &> registration_err.log &
    echo "Permissioning: " $!
else
    echo "Skipping execution of permissioning binary."
fi

if [[ -z ${runServer} ]]; then
    for i in $(seq $nodes $END); do 
        x=$(($i - 1))
        "$BIN_PATH"/server.binary --config "$CONFIG_PATH/servers/server-$x.yml" -i $x \
        --metricsWhitespace ${noTls} -l 1 ${disablePermissioning} &> server$x\_err.log &
        echo "Server $x: " $!
    done
else
    echo "Skipping execution of server binary."
fi

if [[ -z ${runGateway} ]]; then
    for i in $(seq $nodes $END); do 
        x=$(($i - 1))
        "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateways/gateway-$x.yml" -i $x -l 1 ${noTls} ${disablePermissioning} \
        &> gw$x\_err.log &> gateway$x\_err.log &
        echo "Gateway $x: " $!
    done
else
    echo "Skipping execution of gateway binary."
fi

if [[ -z ${runUDB} ]]; then
    "$BIN_PATH"/udb.binary --config "$CONFIG_PATH/udb.yml" ${noTls} -l 1 &> udb_error.log &
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

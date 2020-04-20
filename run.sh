#!/usr/bin/env bash

# Clear out the previous run's logs
rm *.log

# Globals
noTls=""
disablePermissioning=""

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
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/registration.binary -c "$CONFIG_PATH/registration.yaml" \
                ${noTls}  ${disablePermissioning}  &> perm_err.log &
    echo "Permissioning: " $!
else
    echo "Skipping execution of permissioning binary."
fi

if [[ -z ${runServer} ]]; then
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-1.yaml" -i 0 \
      --metricsWhitespace ${noTls} ${disablePermissioning} &> server1_err.log &
    echo "Server 1: " $!
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-2.yaml" -i 1 \
     --metricsWhitespace ${noTls} ${disablePermissioning} &> server2_err.log &
    echo "Server 2: " $!
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-3.yaml" -i 2 \
     --metricsWhitespace ${noTls} ${disablePermissioning} &> server3_err.log &
    echo "Server 3: " $!
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-4.yaml" -i 3 \
     --metricsWhitespace ${noTls} ${disablePermissioning} &> server4_err.log &
    echo "Server 4: " $!
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-5.yaml" -i 4 \
     --metricsWhitespace ${noTls} ${disablePermissioning} &> server5_err.log &
    echo "Server 5: " $!
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary --config "$CONFIG_PATH/server-6.yaml" -i 5 \
     --metricsWhitespace ${noTls} ${disablePermissioning} &> server6_err.log &
    echo "Server 6: " $!
else
    echo "Skipping execution of server binary."
fi

if [[ -z ${runGateway} ]]; then
   GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info  "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-1.yaml" -i 0  ${noTls} ${disablePermissioning} \
    &> gw1_err.log &
    echo "Gateway 1: " $!
   GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info  "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-2.yaml" -i 1  ${noTls} ${disablePermissioning} \
    &> gw2_err.log&
    echo "Gateway 2: " $!
   GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-3.yaml" -i 2  ${noTls} ${disablePermissioning} \
    &> gw3_err.log &
    echo "Gateway 3: " $!
   GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info  "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-4.yaml" -i 3  ${noTls} ${disablePermissioning} \
    &> gw4_err.log &
    echo "Gateway 4: " $!
   GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info  "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-5.yaml" -i 4  ${noTls} ${disablePermissioning} \
    &> gw5_err.log&
    echo "Gateway 5: " $!
   GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/gateway.binary --config "$CONFIG_PATH/gateway-6.yaml" -i 5  ${noTls} ${disablePermissioning} \
    &> gw6_err.log &
    echo "Gateway 6: " $!
else
    echo "Skipping execution of gateway binary."
fi


if [[ -z ${runUDB} ]]; then
    "$BIN_PATH"/udb.binary --config "$CONFIG_PATH/udb.yaml" ${noTls} &
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

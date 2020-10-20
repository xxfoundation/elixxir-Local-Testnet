#!/usr/bin/env bash
# Clear out the previous run's logs
rm gateway*-knownRound
rm errServer-*
rm *.log
rm roundId.txt
rm *-knownRound
# Globals

# Allow for verbose gRPC logs
export GRPC_GO_LOG_VERBOSITY_LEVEL=99
export GRPC_GO_LOG_SEVERITY_LEVEL=info


nodes=$(ls -1q configurations/server-*.yml | wc -l | xargs)
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

    esac
done
BIN_PATH="$(pwd)/binaries"
CONFIG_PATH="$(pwd)/configurations"
if [[ -z ${runPermissioning} ]]; then
    GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/registration.binary \
    --logLevel 2 -c "$CONFIG_PATH/registration.yml" &> registration_err.log &
    echo "Permissioning: " $!
else
    echo "Skipping execution of permissioning binary."
fi
if [[ -z ${runServer} ]]; then
    for i in $(seq $nodes $END); do
        x=$(($i - 1))
        GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/server.binary \
        -l 2 --config "$CONFIG_PATH/server-$x.yml" &> server$x\_err.log &
        echo "Server $x: " $!
    done
else
    echo "Skipping execution of server binary."
fi
if [[ -z ${runGateway} ]]; then
    for i in $(seq $nodes $END); do
        x=$(($i - 1))
        GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info "$BIN_PATH"/gateway.binary \
        --logLevel 2 --config "$CONFIG_PATH/gateway-$x.yml" &> gw$x\_err.log &
        echo "Gateway $x: " $!
    done
else
    echo "Skipping execution of gateway binary."
fi

sleep 4

# fixme: Uncomment when UDB is fixed
#if [[ -z ${runUDB} ]]; then
#    "$BIN_PATH"/udb.binary --config "$CONFIG_PATH/udb.yml" ${noTls} -l 1 &> udb_error.log &
#    echo "UDB: " $!
#else
#    echo "Skipping execution of UDB binary."
#fi
# Pipe child PIDs into file
jobs -p > "pids.tmp"
finish() {
    # Read in and kill all child PIDs
    for job in $(cat pids.tmp)
    do
        echo "KILLING $job"
        kill -9 "$job" || true
    done
}
# Execute finish function on exit
trap finish EXIT
# Wait until user input to exit
read -p 'Press enter to exit...'

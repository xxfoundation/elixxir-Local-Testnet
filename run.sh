#!/usr/bin/env bash
# Clear out the previous run's logs
rm gateway*-knownRound
rm errServer-*
rm *.log
rm roundId.txt
rm *-knownRound
rm updateId*
rm lastupdateid*
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

echo "STARTING SERVERS..."

UDBID=$(binaries/client init -s udbsession -l udbidgen.log --password hello --ndf ndf.json)
echo "GENERATED UDB ID: $UDBID"
UDBID=$(sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//' <<<"$UDBID")
cp configurations/permissioning.yml configurations/permissioning-actual.yml
sed -i "s/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMD/$UDBID/g" configurations/permissioning-actual.yml

# Run Permissioning
if [[ -z ${runPermissioning} ]]; then
    "$BIN_PATH"/permissioning \
    --logLevel 2 -c "$CONFIG_PATH/permissioning-actual.yml" &> registration_err.log &
    echo "Permissioning: " $!
else
    echo "Skipping execution of permissioning binary."
fi

# Run server
if [[ -z ${runServer} ]]; then
    for i in $(seq $nodes $END); do
        x=$(($i - 1))
        "$BIN_PATH"/server \
        -l 2 --config "$CONFIG_PATH/server-$x.yml" &> server$x\_err.log &
        echo "Server $x: " $!
    done
else
    echo "Skipping execution of server binary."
fi

# Run Gateway
if [[ -z ${runGateway} ]]; then
    for i in $(seq $nodes $END); do
        x=$(($i - 1))
        "$BIN_PATH"/gateway \
        --logLevel 0 --config "$CONFIG_PATH/gateway-$x.yml" &> gw$x\_err.log &
        echo "Gateway $x: " $!
    done
else
    echo "Skipping execution of gateway binary."
fi

sleep 4


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

echo "You can't use the network until rounds run."
echo "If it doesn't happen after 1 minute, please Ctrl+C"
echo "and review logs for what went wrong."
rm rid.txt || true
touch rid.txt
echo -n "Waiting for rounds to run..."
while [ ! -s rid.txt ]; do
    sleep 1
    grep -a "RID 1 ReceiveFinishRealtime END" server-2.log > rid.txt || true
    echo -n "."
done
UDBOUT=udb.log

# Run UDB
if [[ -z ${runUDB} ]]; then
# Start a user discovery bot server
    echo "STARTING UDB..."
    UDBCMD="binaries/udb --logLevel 3 --config udb.yml -l 1 --devMode"
    $UDBCMD >> $UDBOUT 2>&1 &
else
    echo "Skipping execution of UDB binary."
fi

echo "\nNetwork rounds have run. You may now attempt to connect."

# Wait until user input to exit
read -p 'Press enter to exit...'

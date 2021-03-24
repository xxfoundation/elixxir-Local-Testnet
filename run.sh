#!/usr/bin/env bash
# Clear out the previous run's logs
rm gateway*-knownRound || true
rm errServer-* || true
rm *.log || true
rm roundId.txt || true
rm *-knownRound || true
rm updateId* || true
rm lastupdateid* || true
rm -r udbsession || true
rm -fr results || true
# Globals
SERVERLOGS=results/servers
GATEWAYLOGS=results/gateways
CLIENTOUT=results/clients
DUMMYOUT=results/dummy-console.txt
UDBOUT=results/udb-console.txt
mkdir -p $SERVERLOGS
mkdir -p $GATEWAYLOGS

# Allow for verbose gRPC logs
export GRPC_GO_LOG_VERBOSITY_LEVEL=99
export GRPC_GO_LOG_SEVERITY_LEVEL=info


nodes=$(ls -1q configurations/server-*.yml | wc -l | xargs)

BIN_PATH="$(pwd)/binaries"
CONFIG_PATH="$(pwd)/configurations"

echo "STARTING SERVERS..."


UDBID=$(binaries/client init -s results/udbsession -l results/udbidgen.log --password hello --ndf ndf.json --writeContact results/udContact.bin)
echo "GENERATED UDB ID: $UDBID"
UDBID=$(sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//' <<<"$UDBID")
cp configurations/permissioning.yml configurations/permissioning-actual.yml
sed -i.bak "s/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMD/$UDBID/g" configurations/permissioning-actual.yml

# Run Permissioning
"$BIN_PATH"/permissioning \
--logLevel 2 -c "$CONFIG_PATH/permissioning-actual.yml" &> results/registration_err.log &

echo "Permissioning: " $!


# Run server
for i in $(seq $nodes $END); do
    x=$(($i - 1))
    "$BIN_PATH"/server \
    -l 2 --config "$CONFIG_PATH/server-$x.yml" &> $SERVERLOGS/server$x\_err.log &

    echo "Server $x: " $!
done

# Run Gateway
for i in $(seq $nodes $END); do
    x=$(($i - 1))
    "$BIN_PATH"/gateway \
    --logLevel 2 --config "$CONFIG_PATH/gateway-$x.yml" &> $GATEWAYLOGS/gw$x\_err.log &

    echo "Gateway $x: " $!
done

echo "You can't use the network until rounds run."
echo "If it doesn't happen after 1 minute, please Ctrl+C"
echo "and review logs for what went wrong."
rm rid.txt || true
touch rid.txt
echo -n "Waiting for rounds to run..."
while [ ! -s rid.txt ]; do
    sleep 1
    grep -a "RID 1 ReceiveFinishRealtime END" results/servers/server-2.log > rid.txt || true
    echo -n "."
done

# Run UDB
# Start a user discovery bot server
echo "STARTING UDB..."
UDBCMD="binaries/udb --logLevel 3 --config configurations/udb.yml -l 1 --devMode"
$UDBCMD >> $UDBOUT 2>&1 &
echo "UDB: " $!

echo "\nNetwork rounds have run. You may now attempt to connect."


sleep 4


# Pipe child PIDs into file
jobs -p > results/serverpids
finish() {
    # Read in and kill all child PIDs
    # NOTE: jobs -p doesn't work in a signal handler
    echo "STOPPING SERVERS AND GATEWAYS..."
    for job in $(cat results/serverpids)
    do
        echo "KILLING $job"
        kill $job || true
    done
    sleep 5

    for job in $(cat results/serverpids)
    do
        echo "KILL -9 $job"
        kill -9 $job || true
    done
}

# Execute finish function on exit
trap finish EXIT
trap finish INT


# Wait until user input to exit
read -p 'Press enter to exit...'

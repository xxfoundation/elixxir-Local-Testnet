import os
import string
import random
import time

# These replace the number order strings, to test that region bucketing works.
secure_strings = ["Americas", "WesternEurope", "CentralEurope", "EasternEurope", "MiddleEast",
"Africa", "Russia", "Asia"]

def randomString(stringLength=4):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))

def makeTLSPair(pairname):
    os.system("openssl req -x509 -nodes -days 730 -newkey rsa:4096 -keyout ../configurations/keys/{}.key -out ../configurations/keys/{}.crt -config cert.conf".format(pairname, pairname))
    #os.system("openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out gen/{}.crt -keyout gen/{}.key -subj \"/C=US/ST=California/L=Claremont/O=Elixxir/OU=LocalEnv Test Cert/CN=elixxir.io\"".format(pairname, pairname))

nodes = int(input("Total number of nodes: "))
minStart = int(input("Minimum number of nodes online to start network: "))
teamSize = int(input("Size of each team: "))
useSecureOrders = bool(input("Use secure order strings: ")) # see: secure_strings


if nodes % len(secure_strings) != 0 and useSecureOrders == True:
    print("[WARN] Inputted nodes is not cleanly divisable by number of secure order strings ({})".format(len(secure_strings)))
    print("[WARN] Script will continue in 3 seconds.")
    time.sleep(3)

if nodes < minStart or nodes < teamSize:
    print("[WARN] minSize or teamSize is higher than the total amount of nodes".format(len(secure_strings)))
    print("[WARN] Script will continue in 3 seconds.")
    time.sleep(3)

if teamSize > minStart:
    print("[WARN] teamSize is over minStart, this could mean registration starts rounds without the minimum number of nodes to sustain it?".format(len(secure_strings)))
    print("[WARN] Script will continue in 3 seconds.")
    time.sleep(3)

# Array of integers for ports of each server and gateway in the network
gateway_ports = []
node_ports = []
node_regCodes = []

server_template = ""
with open("server.yml") as f:
    server_template = f.read()

gateway_template = ""
with open("gateway.yml") as f:
    gateway_template = f.read()

reg_template = ""
with open("registration.yml") as f:
    reg_template = f.read()

reg_json_template = ""
with open("registration.json") as f:
    reg_json_template = f.read()

# Generate a list of all ports servers and gateways occupy. Doing this as a
# separate step because their configs need every one listed, and generating them
# once is lighter on CPU cycles.
for i in range(nodes):
    gateway_ports.append(8200+i)
    node_ports.append(11200+i)

    regCode = randomString()
    # If this regCode is already in the list, we loop until we get one that
    # isn't
    while regCode in node_regCodes:
        regCode = randomString()
    node_regCodes.append(regCode)

# Generate server and gateway configs
for i in range(nodes):
    with open("../configurations/servers/server-{}.yml".format(i), 'w') as f:
        # Array of strings defining node and gateway IPs and ports
        node_addr = []
        gate_addr = []
        node_addr.append("{}".format(node_ports[i]))
        gate_addr.append("\"0.0.0.0:{}\"".format(gateway_ports[i]))

        # Create a new config based on template
        s_config = server_template.replace("server-1", "server-" + str(i)) \
            .replace("gateway-1", "gateway-" + str(i)) \
            .replace("{NODE_ADDR}", "".join(node_addr)) \
            .replace("{GATE_ADDR}", "".join(gate_addr)) \
            .replace("{DB_ADDR}", "\r\n".join(["\"\""])) \
            .replace("AAAA", node_regCodes[i]) \
            .replace("nodeID-1.json", "nodeID-"+str(i)+".json")
        f.write(s_config)

        makeTLSPair("server-" + str(i))

    with open("../configurations/gateways/gateway-{}.yml".format(i), 'w') as f:
        # Array of strings defining node and gateway IPs and ports
        node_addr = []
        node_addr.append("\"0.0.0.0:{}\"".format(node_ports[i]))

        # Create a new config based on template
        g_config = gateway_template.replace("server-1", "server-" + str(i)) \
            .replace("gateway-1", "gateway-" + str(i)) \
            .replace("8200", str(gateway_ports[i])) \
            .replace("{NODE_ADDR}", "\r\n".join(node_addr)) \
            .replace("gatewayIDF", "gatewayIDF-" + str(i))
        f.write(g_config)

        makeTLSPair("gateway-" + str(i))

# Generate permissioning stuff
makeTLSPair("permissioning")
with open("../configurations/registration.json", "w") as f:
    config = reg_json_template.replace("{teamSize}", str(teamSize))
    f.write(config)
with open("../configurations/registration.yml", "w") as f:
    config = reg_template.replace("{minStart}", str(minStart))
    f.write(config)

# Generate server regCodes file
with open("../configurations/regCodes.json", "w") as f:
    f.write("[")

    for i in range(nodes):
        # Generate the order string to use
        order = ""
        if useSecureOrders:
            order = secure_strings[i % len(secure_strings)]
        else:
            order = str(i)

        f.write("{\"RegCode\": \"" + node_regCodes[i] + "\", \"Order\": \"" + \
            order + "\"}")

        # If not the last element, write a comma
        if i is not (nodes - 1):
            f.write(",")

    f.write("]")
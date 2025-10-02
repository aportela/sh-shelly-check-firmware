#!/bin/sh

# 2025-10-02 tests made with
# Devices: Shelly PlusPlugS (firmware 1.7.0)

# curl required (for requests)
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl not found."
    exit 1
fi

# jq required (for json parsing)
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq not found."
    exit 1
fi

show_help() {
    echo "Usage: $0 configuration_path"
    exit 1
}

if [ $# -ge 1 ]; then
    if [ -f "$1" ]; then
        CONFIGURATION_FILE="$1"
        . "$CONFIGURATION_FILE"
    else
        echo "Error: configuration file '$1' does not exist."
        exit 1
    fi
else
    show_help
fi

# for each device
for host in $DEVICE_HOSTS; do
    # generate shelly RPC API url
    SHELLY_HOST_RPC_URL="http://$host/rpc"

    METHOD="Shelly.GetDeviceInfo"
    # get shelly RPC API (JSON) response
    RPC_RESPONSE=$(curl -s --anyauth -u "admin:$SHELLY_PASSWORD" -X GET "$SHELLY_HOST_RPC_URL/$METHOD" -H "Content-Type: application/json")

    if [ $? -ne 0 ]; then
        # shelly RPC API error
        echo "Shelly RPC API ERROR: Host: $host, RPC URL: $SHELLY_HOST_RPC_URL/$METHOD"
        continue
    fi

    SHELLY_DEVICE_CURRENT_VERSION=$(echo "$RPC_RESPONSE" | jq -r '.ver // empty')

    METHOD="Shelly.CheckForUpdate"
    # get shelly RPC API (JSON) response
    RPC_RESPONSE=$(curl -s --anyauth -u "admin:$SHELLY_PASSWORD" -X GET "$SHELLY_HOST_RPC_URL/$METHOD" -H "Content-Type: application/json")

    if [ $? -ne 0 ]; then
        # shelly RPC API error
        echo "Shelly RPC API ERROR: Host: $host, RPC URL: $SHELLY_HOST_RPC_URL/$METHOD"
        continue
    fi

    LATEST_VERSION_STABLE=$(echo "$RPC_RESPONSE" | jq -r '.stable.version // empty')
    LATEST_VERSION_BETA=$(echo "$RPC_RESPONSE" | jq -r '.beta.version // empty')

    if [ -n "$LATEST_VERSION_STABLE" ]; then
        if [ -n "$LATEST_VERSION_BETA" ]; then
            echo "Device: $host - Update available (current: $SHELLY_DEVICE_CURRENT_VERSION => stable: $LATEST_VERSION_STABLE, beta: $LATEST_VERSION_BETA)"
        else
            echo "Device: $host - Update available (current: $SHELLY_DEVICE_CURRENT_VERSION => stable: $LATEST_VERSION_STABLE)"
        fi

    else
        if [ -z "$ONLY_SHOW_UPDATES" ]; then
            echo "Device: $host - No update available (current: $SHELLY_DEVICE_CURRENT_VERSION)"
        fi
    fi

done

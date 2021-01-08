#!/usr/bin/env bash

# Set fail flags
set -eo pipefail

GREEN='\033[0;32m'
NC='\033[0m' # No Color

log() {
    printf '%b\n' "${GREEN}${1}${NC}"
    echo ""
}

addAddress() {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$FNC_CONFIG" ] 
      then
        echo "addAddress: No argument supplied"
        exit 1
    fi
    cat "$FNC_CONFIG" | jq --arg key "$1" --arg value "$2" '.[$key] = $value' | sponge "$FNC_CONFIG"
    log "$1=$2"
}

toUpper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

toLower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}


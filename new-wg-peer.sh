#!/bin/bash

readonly INTERFACE="wg0"
readonly ENDPOINT="changeWithYourEndpoint.com:51820"
readonly DNS="1.1.1.1,8.8.8.8"

# Generate peer keys
readonly PRIVATE_KEY=$(wg genkey)
readonly PUBLIC_KEY=$(echo ${PRIVATE_KEY} | wg pubkey)
readonly PRESHARED_KEY=$(wg genpsk)

# Read server key from interface
readonly SERVER_PUBLIC_KEY=$(wg show ${INTERFACE} public-key)

# Get next free peer IP (This will break after x.x.x.255)
readonly PEER_ADDRESS=$(wg show ${INTERFACE} allowed-ips | cut -f 2 | awk -F'[./]' '{print $1"."$2"."$3"."1+$4"/"$5}' | sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -n | tail -n1)

# Add peer
wg set ${INTERFACE} peer ${PUBLIC_KEY} allowed-ips ${PEER_ADDRESS}

# Logging
echo "Added peer ${PEER_ADDRESS} with public key ${PUBLIC_KEY}"

# Generate peer config QR code
conf=$(cat <<END_OF_CONFIG
[Interface]
Address = ${PEER_ADDRESS}
PrivateKey = ${PRIVATE_KEY}
DNS = ${DNS}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
AllowedIPs = 0.0.0.0/0
Endpoint = ${ENDPOINT}
END_OF_CONFIG
)

echo "$conf" | qrencode -t ANSIUTF8
echo "$conf"

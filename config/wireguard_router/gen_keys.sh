#!/bin/bash

TEAM_IP_PREFIX="10.0.0."

if ! command -v wg; then
    echo "The command wg does not exist."
    exit 1;
fi

if [ "$#" -ne 1 ]; then
    echo "Please specify a number of teams. Usage: $0 <no of teams>"
    exit 1;
fi

if ! [ "$1" -ge 1 ] || ! [ "$1" -le 240 ]; then
    echo "The number of teams must be between 1 and 240."
    exit 1;
fi

for team_id in $(seq 1 "$1"); do
    team_ip="${TEAM_IP_PREFIX}${team_id}"
    echo $TEAM_IP
    privkey=$(wg genkey)
    echo $privkey
    echo $team_id
done

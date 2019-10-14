#!/bin/bash

gameserver="$(virsh domifaddr enovm_gameserver | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
echo "Found gameserver at $gameserver"

iptables -I POSTROUTING -t nat -j MASQUERADE
iptables -I FORWARD -i enp10s0 -j ACCEPT

for i in {1..2}
do
    vulnbox="$(virsh domifaddr enovm_vulnbox$i | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
    port=$(( 65000 + $i ))
    vpnport=$(( 30000 + $i ))
    echo "Exposing wireguard port of vulnbox$i on $port"
    iptables -A PREROUTING -t nat -p udp --dport $port -j DNAT --to-destination $vulnbox:1194
    echo "Exposing openvpn server for vulnbox$i on $vpnport"
    iptables -A PREROUTING -t nat -p tcp --dport $vpnport -j DNAT --to-destination $gameserver:$vpnport
done

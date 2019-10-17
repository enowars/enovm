#!/bin/bash

gameserver="$(virsh domifaddr enovm_gameserver | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
echo "Found gameserver at $gameserver"

iptables -I POSTROUTING -t nat -j MASQUERADE
iptables -I FORWARD -i enp10s0 -j ACCEPT                                                        # Allow forwarding from enp10s0
iptables -A PREROUTING -i enp10s0 -t nat -p tcp --dport 80 -j DNAT --to-destination $gameserver:80         # Map port 80 to gameserver:80
iptables -A PREROUTING -i enp10s0 -t nat -p tcp --dport 65000 -j DNAT --to-destination $gameserver:22      # Map port 65000 to gameserver:80

for i in {1..2}
do
    vulnbox="$(virsh domifaddr enovm_vulnbox$i | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
    port=$(( 65000 + $i ))
    vpnport=$(( 30000 + $i ))
    echo "Exposing wireguard port of vulnbox$i on $port udp"
    iptables -A PREROUTING -t nat -p udp --dport $port -j DNAT --to-destination $vulnbox:1194
    echo "Exposing openvpn server for vulnbox$i on $vpnport"
    iptables -A PREROUTING -t nat -p tcp --dport $vpnport -j DNAT --to-destination $gameserver:$vpnport
    echo "Exposing sshd for vulnbox$i on $port tcp"
    iptables -A PREROUTING -i enp10s0 -t nat -p tcp --dport $port -j DNAT --to-destination $vulnbox:22
done

conntrack --flush

#!/bin/sh

gameserver="$(virsh domifaddr enovm_gameserver | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"

echo "Found gameserver at $gameserver"

iptables -A PREROUTING -t nat -p tcp --dport 30000 -j DNAT --to-destination $gameserver:30000
iptables -I POSTROUTING -t nat -j MASQUERADE

for i in {1..2}
do
    vulnbox="$(virsh domifaddr enovm_vulnbox$i | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')"
    port=$(( 65000 + $i ))
    echo "Exposing wireguard port of vulnbox$i on $port"
    iptables -A PREROUTING -t nat -p udp --dport $port -j DNAT --to-destination $vulnbox:1194
done

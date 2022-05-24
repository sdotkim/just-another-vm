#!/usr/bin/env bash

cp -f $(ls /etc/openvpn/client/configs/*.ovpn|sort -R | head -n 1) /etc/openvpn/client/client.conf

if grep -Fq "auth-user-pass" /etc/openvpn/client/client.conf
then
    sed -i 's+auth-user-pass.*+auth-user-pass client_credentials+g' /etc/openvpn/client/client.conf
else
    sed -i 's+remote-cert-tls.*+&\n\nauth-user-pass client_credentials\n+' /etc/openvpn/client/client.conf
fi

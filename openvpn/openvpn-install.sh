#!/bin/bash
# ===========================================
#  Auto Install OpenVPN Server (Ubuntu/Debian)
#  Subnet: 10.8.10.0/22 (1022 clients)
# ===========================================

if [ "$EUID" -ne 0 ]; then
  echo "⚠️ Harus dijalankan sebagai root!"
  exit
fi

VPN_IP=$(curl -s ifconfig.me)
VPN_PORT=1194
VPN_PROTO=udp

echo "==================================="
echo " Install OpenVPN Server"
echo " VPS IP   : $VPN_IP"
echo " Port     : $VPN_PORT"
echo " Proto    : $VPN_PROTO"
echo " Subnet   : 10.8.10.0/22"
echo "==================================="

# Update system
apt update -y && apt upgrade -y

# Install OpenVPN & EasyRSA
apt install openvpn easy-rsa iptables-persistent -y

# Setup PKI
make-cadir ~/openvpn-ca
cd ~/openvpn-ca || exit

./easyrsa init-pki
echo -ne "\n" | ./easyrsa build-ca nopass
./easyrsa gen-req server nopass
echo "yes" | ./easyrsa sign-req server server
./easyrsa gen-dh

# Copy keys ke /etc/openvpn
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/

# Buat server.conf
cat > /etc/openvpn/server.conf <<EOF
port $VPN_PORT
proto $VPN_PROTO
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.8.0 255.255.252.0
client-config-dir /etc/openvpn/ccd
topology subnet
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# NAT rules
iptables -t nat -A POSTROUTING -s 10.8.10.0/22 -o eth0 -j MASQUERADE
netfilter-persistent save

# Start OpenVPN
systemctl start openvpn@server
systemctl enable openvpn@server

echo "==================================="
echo "✅ OpenVPN Server berhasil diinstall!"
echo "📌 Subnet : 10.8.10.0/22"
echo "📌 Config : /etc/openvpn/server.conf"
echo "==================================="


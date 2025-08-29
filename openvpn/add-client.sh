#!/bin/bash
# ===========================================
#  Add OpenVPN Client + Static IP
#  Works with server subnet 10.8.10.0/22
# ===========================================

if [ "$EUID" -ne 0 ]; then
  echo "⚠️ Harus dijalankan sebagai root!"
  exit
fi

CLIENT=$1
STATIC_IP=$2

if [ -z "$CLIENT" ] || [ -z "$STATIC_IP" ]; then
  echo "🔧 Usage: $0 <nama_client> <static_ip>"
  echo "Contoh: $0 andi 10.8.10.50"
  exit 1
fi

VPN_IP=$(curl -s ifconfig.me)
VPN_PORT=1194
VPN_PROTO=udp
OVPN_DIR=~/client-configs
CCD_DIR=/etc/openvpn/ccd

mkdir -p $OVPN_DIR
mkdir -p $CCD_DIR

cd ~/openvpn-ca || exit

# Buat certificate client
./easyrsa gen-req $CLIENT nopass
echo "yes" | ./easyrsa sign-req client $CLIENT

# File CCD untuk static IP
cat > $CCD_DIR/$CLIENT <<EOF
ifconfig-push $STATIC_IP 255.255.252.0
EOF

# Buat file client OVPN
cat > $OVPN_DIR/$CLIENT.ovpn <<EOF
client
dev tun
proto $VPN_PROTO
remote $VPN_IP $VPN_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
verb 3

<ca>
$(cat pki/ca.crt)
</ca>

<cert>
$(cat pki/issued/$CLIENT.crt)
</cert>

<key>
$(cat pki/private/$CLIENT.key)
</key>
EOF

mkdir -p "/etc/openvpn/client/$CLIENT"
chown -R ubuntu:ubuntu "/etc/openvpn/client/$CLIENT"
cp pki/ca.crt "$OVPN_DIR/$CLIENT.ovpn" "pki/issued/$CLIENT.crt" "pki/private/$CLIENT.key" "/etc/openvpn/client/$CLIENT/"

echo "==================================="
echo "✅ Client $CLIENT berhasil dibuat!"
echo "📌 File OVPN : $OVPN_DIR/$CLIENT.ovpn"
echo "📌 Static IP : $STATIC_IP"
echo "==================================="


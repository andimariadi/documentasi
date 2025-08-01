# 🔧 Setup x11vnc di Raspberry Pi dengan Systemd Service

Panduan ini menjelaskan cara menginstal dan mengatur `x11vnc` agar otomatis berjalan saat boot dan menampilkan layar HDMI (`:0`) melalui VNC.

---

## ✅ 1. Instal `x11vnc`

```bash
sudo apt update
sudo apt install x11vnc -y
```

---

## ✅ 2. Nonaktifkan VNC Lama (Opsional)

Jika sebelumnya menggunakan `vncserver`:

```bash
sudo systemctl disable pi-vnc-tunnel.service
sudo systemctl stop pi-vnc-tunnel.service
```

Atau:

```bash
sudo systemctl disable vncserver@1.service
sudo systemctl stop vncserver@1.service
```

---

## ✅ 3. Buat Service Systemd untuk x11vnc

Buat file service:

```bash
sudo nano /etc/systemd/system/pi-vnc-tunnel.service
```

Isi file:

```ini
[Unit]
Description=Start x11vnc to mirror HDMI display at boot
After=network-online.target
Wants=network-online.target

[Service]
User=pi
ExecStart=/usr/bin/x11vnc -display :0 -auth guess -forever -nopw
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

## ✅ 4. Aktifkan dan Jalankan Servicenya

```bash
sudo systemctl daemon-reload
sudo systemctl enable pi-vnc-tunnel.service
sudo systemctl start pi-vnc-tunnel.service
```

Cek status:

```bash
systemctl status pi-vnc-tunnel.service
```

---

## 🔐 (Opsional) Tambahkan Password

```bash
x11vnc -storepasswd yourpassword ~/.vnc/passwd
```

Edit service:

```ini
ExecStart=/usr/bin/x11vnc -display :0 -auth guess -forever -rfbauth /home/pi/.vnc/passwd
```

Lalu reload dan restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart pi-vnc-tunnel.service
```

---

## 🎉 Selesai

Sekarang Raspberry Pi kamu akan otomatis menjalankan VNC saat boot dan menampilkan tampilan HDMI (`:0`). VNC client bisa langsung connect ke port 5900/5901 Raspberry Pi.
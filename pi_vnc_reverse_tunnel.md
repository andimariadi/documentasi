# 📡 Raspberry Pi Reverse Tunnel to VPS for VNC Access

Dokumentasi setup reverse SSH tunnel dari Raspberry Pi menggunakan koneksi seluler (SIM Card), agar dapat diakses dari luar via VPS hanya dengan 1 port (5900).

---

## ✅ 1. Membuat User Khusus Tunnel di VPS

Login ke VPS:

```bash
sudo adduser pi_tunnel
sudo usermod -s /bin/bash pi_tunnel
```

Buka port SSH alternatif (misal `22`) di `/etc/ssh/sshd_config`:

```text
Port 22
Port 22
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

---

## ✅ 2. Setup SSH Key dari Raspberry Pi

Di Raspberry Pi:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
ssh-copy-id -p 22 pi_tunnel@<IP_VPS>
```

Pastikan SSH key login berhasil tanpa password:

```bash
ssh -p 22 pi_tunnel@<IP_VPS>
```

---

## ✅ 3. Menyalakan VNC Server di Raspberry Pi

Install dan jalankan TightVNC:

```bash
sudo apt install tightvncserver
vncserver :1
```

Display `:1` = port 5901

---

## ✅ 4. Membuat Reverse SSH Tunnel dari Raspberry Pi ke VPS

```bash
ssh -p 22 -N -R 0.0.0.0:5900:localhost:5901 pi_tunnel@<IP_VPS>
```

Artinya:

> VPS port 5900 → diteruskan ke Raspberry Pi `localhost:5901`

---

## ✅ 5. Membuat Systemd Service di Raspberry Pi

File: `/etc/systemd/system/pi-vnc-tunnel.service`

```ini
[Unit]
Description=Start VNC server and reverse tunnel to VPS
After=network-online.target
Wants=network-online.target

[Service]
User=pi
Type=simple
ExecStartPre=/usr/bin/vncserver -kill :1
ExecStart=/bin/bash -c '/usr/bin/vncserver :1 && /usr/bin/ssh -i /home/pi/.ssh/id_rsa -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N -R 0.0.0.0:5900:localhost:5901 -p 22 pi_tunnel@<IP_VPS>'
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Aktifkan:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable pi-vnc-tunnel
sudo systemctl start pi-vnc-tunnel
```

---

## ✅ 6. Uji Koneksi VNC dari Laptop

Di sisi laptop/klien (install TigerVNC Viewer):

```bash
vncviewer <IP_VPS>:5900
```

✅ Tampilan desktop Raspberry Pi akan muncul 🎉

---

## 💡 Catatan

- Hanya **satu Raspberry Pi** yang bisa aktif di port `5900` dalam satu waktu.
- Bisa digunakan bergantian, atau dengan script iptables switcher.
- Semua koneksi terenkripsi melalui SSH reverse tunnel, tanpa perlu IP publik di Raspberry Pi.

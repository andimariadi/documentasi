# OPENVPN Installation Scripts

Repositori ini berisi skrip untuk instalasi dan penambahan klien OpenVPN secara otomatis di server Linux.

## Daftar File

- `openvpn-install.sh`: Skrip utama untuk instalasi OpenVPN di server.
- `add-client.sh`: Skrip untuk menambahkan klien baru ke server OpenVPN.

## Cara Penggunaan

### 1. Instalasi OpenVPN

Jalankan skrip `openvpn-install.sh` pada server Linux Anda:

```bash
bash openvpn-install.sh
```

Ikuti instruksi yang muncul untuk menyelesaikan proses instalasi.

### 2. Menambah Klien Baru

Setelah OpenVPN terinstal, gunakan skrip `add-client.sh` untuk menambah klien:

```bash
bash add-client.sh
```

Masukkan nama klien sesuai instruksi, lalu file konfigurasi klien akan dibuat.

## Catatan

- Skrip ini dirancang untuk dijalankan di sistem operasi Linux.
- Pastikan Anda memiliki akses root/sudo untuk menjalankan skrip.
- Untuk keamanan, pastikan server Anda sudah diperbarui sebelum instalasi.

## Kontribusi

Silakan buat pull request atau buka issue jika ingin berkontribusi atau melaporkan masalah.

## Lisensi

Skrip ini menggunakan lisensi MIT. Silakan gunakan dan modifikasi sesuai kebutuhan.

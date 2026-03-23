# ArgoCD Quick Setup Guide

Direktori ini berisi skrip otomatisasi untuk menginstal ArgoCD dengan bersih dan aman di cluster Kubernetes lokal (`k3d`). 

## Instalasi Otomatis (1-Klik)

Skrip `setup.sh` telah diprogram secara khusus untuk mengabaikan error seputar ukuran anotasi CRD yang usang dengan menggunakan fitur `--server-side` dari Kubernetes modern.

### Perintah Instalasi
Buka terminal dan navigasikan ke dalam folder `argocd` ini, lalu jalankan dua perintah berikut:

```bash
# 1. Jadikan script bisa dieksekusi (hanya diperlukan 1 kali)
chmod +x setup.sh

# 2. Eksekusi script instalasi
./setup.sh
```

Skrip ini akan memakan waktu kurang lebih **1-2 menit** untuk memastikan setiap *Pod* di dalam namespace `argocd` telah berstatus `Ready` sebelum kembali ke tangan Anda.

---

## Tahap Lanjutan Setelah Instalasi

### 1. Dapatkan Password Login
Secara terpusat, Username untuk login ke UI (Dashboard) adalah `admin`. 
Untuk mendapatkan pasangan kata sandi unik yang digenerate oleh database internal ArgoCD, lakukan penyalinan rahasia dengan dekripsi string Base64:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 2. Membuka Akses Dashboard (UI) Tanpa Port-Forward
Skrip setup kini telah secara otomatis mengekspos ArgoCD melalui fitur **NodePort** di port `32025` secara permanen. Anda **TIDAK PERLU** lagi menyalakan perintah port-forward dan membiarkan terminal terbuka!

### 3. Login!
Kapanpun Anda ingin mengakses ArgoCD, cukup buka browser (Chrome / Safari) Anda ke alamat ini:
👉 **[https://localhost:32025](https://localhost:32025)**

*(Abaikan peringatan "Connection is not private" jika muncul, karena sertifikatnya bersifat *self-signed*).*

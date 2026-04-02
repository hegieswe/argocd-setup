#!/bin/bash
set -eo pipefail

echo "🚀 Memulai instalasi ArgoCD secara otomatis di Kubernetes lokal..."

echo -e "\n[1/3] Membuat namespace 'argocd' (jika belum ada)..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo -e "\n[2/3] Menginstal manifest ArgoCD..."
echo "      (Metode: --server-side --force-conflicts untuk mengatasi error batas ukuran 256KB CRD)"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side --force-conflicts > /dev/null

echo -e "\n[3/4] Menunggu semua Pod ArgoCD berstatus \"Ready/Running\" (bisa memakan waktu 1-3 menit)..."
# Kami menunggu Pod yang memiliki label argocd khusus
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo -e "\n[4/4] Mengubah konfigurasi jaringan agar bisa diakses TANPA port-forward..."
# Mengubah service ArgoCD menjadi NodePort dan mengikatnya di port 32025 (port yang sudah Anda buka di k3d)
cat <<EOF > patch-argocd-svc.yaml
spec:
  type: NodePort
  ports:
    - name: https
      port: 443
      targetPort: 8080
      nodePort: 31804
EOF
kubectl patch svc argocd-server -n argocd --patch-file patch-argocd-svc.yaml 2>/dev/null || true
rm patch-argocd-svc.yaml

echo -e "\n✅ Instalasi ArgoCD Berhasil Sempurna!"
echo "───────────────────────────────────────────────────────"
echo "🔐 CARA MENDAPATKAN PASSWORD LOGIN:"
echo "Username bawaan adalah: admin"
echo "Jalankan perintah di bawah ini untuk menampilkan (dekripsi) password awal Anda:"
echo -e "\033[1mkubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo\033[0m"
echo ""
echo "🌐 CARA MENGAKSES UI DASHBOARD (PERMANEN):"
echo "Anda TIDAK PERLU lagi melakukan port-forward!"
echo "Langsung saja buka browser komputer Anda ke alamat:"
echo -e "\033[1mhttps://localhost:32025\033[0m"
echo "───────────────────────────────────────────────────────"

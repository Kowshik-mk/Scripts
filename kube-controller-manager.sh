#!/bin/bash

# Exit on error
set -e

echo "[+] Creating systemd service for kube-controller-manager..."

SERVICE_FILE="/etc/systemd/system/kube-controller-manager.service"

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://kubernetes.io/docs/home/
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
  --authentication-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
  --authorization-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
  --bind-address=127.0.0.1 \\
  --leader-elect=true \\
  --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt \\
  --cluster-signing-key-file=/etc/kubernetes/pki/ca.key \\
  --root-ca-file=/etc/kubernetes/pki/ca.crt \\
  --service-account-private-key-file=/etc/kubernetes/pki/sa.key \\
  --use-service-account-credentials=true \\
  --controllers=*,bootstrapsigner,tokencleaner

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Reloading systemd daemon..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "[+] Enabling and starting kube-controller-manager..."
sudo systemctl enable kube-controller-manager
sudo systemctl start kube-controller-manager

echo "[+] Checking status..."
sudo systemctl status kube-controller-manager --no-pager


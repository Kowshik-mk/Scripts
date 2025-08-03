#!/bin/bash

# Set version
ETCD_VER="v3.5.13"

# Download etcd
echo "📦 Downloading etcd $ETCD_VER..."
DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

# Extract and install
echo "📂 Extracting and installing etcd..."
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp
sudo mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcd* /usr/local/bin/

# Create etcd systemd service
echo "⚙️ Creating etcd systemd service..."
sudo tee /etc/systemd/system/etcd.service > /dev/null <<EOF
[Unit]
Description=etcd key-value store
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name standalone-etcd \\
  --data-dir=/var/lib/etcd \\
  --listen-client-urls=http://127.0.0.1:2379 \\
  --advertise-client-urls=http://127.0.0.1:2379
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable etcd
echo "🔁 Enabling and starting etcd service..."
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

# Show service status
echo "✅ etcd service status:"
sudo systemctl status etcd --no-pager


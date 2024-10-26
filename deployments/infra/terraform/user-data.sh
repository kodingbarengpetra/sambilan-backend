#! /bin/bash
apt update -y
apt install -y nginx

mkdir -p /app
cat <<EOF > /app/sambilan-backend.service
#!/bin/bash
# infinite loop
while true; do
    echo "Sambilan Backend is running"
    sleep 10
done
EOF
chmod +x /app/sambilan-backend.service
chown ubuntu:ubuntu /app/sambilan-backend.service

cat <<EOF > /lib/systemd/system/sambilan-backend.service
[Unit]
Description=Sambilan Backend

[Service]
WorkingDirectory=/app
ExecStart=/app/sambilan-backend.service

[Install]
WantedBy=multi-user.target
EOF

systemctl enable sambilan-backend.service
systemctl start sambilan-backend.service

cat <<EOF > /etc/nginx/sites-available/default
server {
    server_name localhost;

    location / {
        proxy_pass http://localhost:3000;
    }
}
EOF

systemctl start nginx
systemctl enable nginx
systemctl reload nginx

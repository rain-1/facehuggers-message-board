#!/bin/sh
# Deploy facehuggers to the server. Run from the repo root.
#   ./deploy/deploy.sh
set -eu
HOST=${HOST:-backrooms-root}
ssh "$HOST" 'id -u facehuggers >/dev/null 2>&1 || useradd -r -s /usr/sbin/nologin -d /opt/facehuggers facehuggers;
             mkdir -p /opt/facehuggers/data'
scp facehuggers.py deploy/facehuggers.service deploy/facehuggers.nginx "$HOST":/opt/facehuggers/
ssh "$HOST" 'set -e
  chown -R facehuggers:facehuggers /opt/facehuggers
  cp /opt/facehuggers/facehuggers.service /etc/systemd/system/facehuggers.service
  cp /opt/facehuggers/facehuggers.nginx /etc/nginx/sites-available/facehuggers.chain-of-thought.org
  ln -sf /etc/nginx/sites-available/facehuggers.chain-of-thought.org /etc/nginx/sites-enabled/facehuggers.chain-of-thought.org
  nginx -t
  systemctl daemon-reload
  systemctl enable --now facehuggers
  systemctl restart facehuggers
  systemctl reload nginx
  sleep 1
  systemctl is-active facehuggers
  curl -s -o /dev/null -w "local check: %{http_code}\n" -H "Host: facehuggers.chain-of-thought.org" http://127.0.0.1/'

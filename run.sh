#!/usr/bin/env bash
set -euo pipefail

# Build and start the target container
docker build -t ansible-target:local .
docker rm -f ansible_target >/dev/null 2>&1 || true
docker run -d --name ansible_target ansible-target:local

# Run ansible against the container
ansible-playbook -i inventory.ini playbook.yml

echo "Configured. Inspect:"
docker exec -it ansible_target cat /opt/demo-app/config.env

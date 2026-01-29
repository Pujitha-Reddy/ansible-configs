#!/usr/bin/env bash
set -euo pipefail

echo "== Build target container =="
docker build -t ansible-target:local .

echo "== Start target container =="
docker rm -f ansible_target >/dev/null 2>&1 || true
docker run -d --name ansible_target ansible-target:local

echo "== Configure container (no docker connection plugin) =="
docker exec -u root -i ansible_target bash -lc '
set -euo pipefail
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y ansible curl

cat > /tmp/playbook.yml <<PLAY
- name: Configure app host
  hosts: localhost
  connection: local
  become: true
  tasks:
    - name: Create app directory
      file:
        path: /opt/demo-app
        state: directory
        mode: "0755"

    - name: Write config file
      copy:
        dest: /opt/demo-app/config.env
        content: |
          ENV=dev
          FEATURE_FLAG=true
        mode: "0644"
PLAY

ansible-playbook -i localhost, /tmp/playbook.yml

echo "== OUTPUT (must print) =="
cat /opt/demo-app/config.env
'

echo "== Done =="

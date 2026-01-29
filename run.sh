#!/usr/bin/env bash
set -euo pipefail

# Build and start the target container
docker build -t ansible-target:local .
docker rm -f ansible_target >/dev/null 2>&1 || true
docker run -d --name ansible_target ansible-target:local

# Run ansible INSIDE the container (no docker connection plugin needed)
docker exec -i ansible_target bash -lc '
  sudo apt-get update -y >/dev/null
  sudo apt-get install -y ansible >/dev/null
  cat > /tmp/playbook.yml <<PLAY
- name: Configure app host
  hosts: localhost
  become: true
  tasks:
    - name: Install packages
      apt:
        name:
          - curl
        state: present
        update_cache: yes

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
  echo "Configured. Inspect:"
  cat /opt/demo-app/config.env
'

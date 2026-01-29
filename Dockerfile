FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y python3 sudo curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m app && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER app
WORKDIR /home/app
CMD ["sleep", "infinity"]

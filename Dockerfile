FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    vim \
    sudo gosu \
    git \
    curl wget \
    net-tools \
    build-essential cmake \
    python3 python3-venv python3-pip \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# エントリポイントスクリプトを作成
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# スクリプトをENTRYPOINTに設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    vim \
    sudo gosu \
    git \
    curl \
    net-tools \
    language-pack-ja \
    build-essential cmake \
    python3 python3-venv python3-pip \
    nodejs npm \
    && update-locale LANG=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

# エントリポイントスクリプトを作成
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# スクリプトをENTRYPOINTに設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

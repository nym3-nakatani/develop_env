FROM osrf/ros:jazzy-desktop

RUN apt-get update && apt-get install -y \
    vim \
    sudo gosu \
    git \
    curl wget \
    net-tools \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    language-pack-ja \
    && rm -rf /var/lib/apt/lists/*
RUN update-locale LANG=ja_JP.utf8 LC_ALL=ja_JP.utf8

RUN apt-get update && apt-get install -y \
    build-essential cmake \
    python3 python3-venv python3-pip \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# エントリポイントスクリプトを作成
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# スクリプトをENTRYPOINTに設定
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

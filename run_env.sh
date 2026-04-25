#!/bin/bash

# OS判定してX11設定を切り替え
if [ "$(uname)" = "Darwin" ]; then
    # macOS: XQuartz使用、host.docker.internal経由
    DISPLAY_VAL="host.docker.internal:0"
    EXTRA_OPTS=""
else
    # Linux: Unix domain socket経由
    DISPLAY_VAL="${DISPLAY:-:0}"
    EXTRA_OPTS=""
fi

# パスワードを対話的に入力させる（履歴に残らない）
read -rsp "Enter sudo password for container: " CONTAINER_PASS
echo

mkdir -p "$HOME/workspace"

USER_ID=$(id -u) \
GROUP_ID=$(id -g) \
USER=$(whoami) \
HOST_PASS="$CONTAINER_PASS" \
DISPLAY_VAL="$DISPLAY_VAL" \
docker compose run --rm $EXTRA_OPTS env

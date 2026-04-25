#!/bin/bash
set -e

# 環境変数からホストのユーザーID、グループID、およびユーザー名を取得
USER_ID=${HOST_UID:?HOST_UID is not set}
GROUP_ID=${HOST_GID:?HOST_GID is not set}
USER=${HOST_USER:?HOST_USER is not set}

#　
if [ "$USER_ID" -lt 1000 ]; then
    sed -i "/UID_MIN/c UID_MIN   500" /etc/login.defs
    sed -i "/SYS_UID_MAX/c SYS_UID_MAX   499" /etc/login.defs
fi
if [ "$GROUP_ID" -lt 1000 ]; then
    sed -i "/GID_MIN/c GID_MIN   500" /etc/login.defs
    sed -i "/SYS_GID_MAX/c SYS_GID_MAX   499" /etc/login.defs
fi

# グループが存在しない場合のみ作成、衝突する場合は退かす
if ! getent group "$GROUP_ID" > /dev/null 2>&1; then
    groupadd -g "$GROUP_ID" "$USER"
else
    EXISTING_GROUP=$(getent group "$GROUP_ID" | cut -d: -f1)
    if [ "$EXISTING_GROUP" != "$USER" ]; then
        echo "GID $GROUP_ID already exists as group '$EXISTING_GROUP', moving it to GID 60000."
        groupmod -g 60000 "$EXISTING_GROUP"
        groupadd -g "$GROUP_ID" "$USER"
    fi
fi

# ユーザーが存在しない場合のみ作成、衝突する場合は退かす
if ! getent passwd "$USER_ID" > /dev/null 2>&1; then
    useradd -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$USER"
else
    EXISTING_USER=$(getent passwd "$USER_ID" | cut -d: -f1)
    if [ "$EXISTING_USER" != "$USER" ]; then
        echo "UID $USER_ID already exists as user '$EXISTING_USER', moving it to UID 60000."
        usermod -u 60000 "$EXISTING_USER"
        useradd -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$USER"
    fi
fi

usermod -aG sudo "$USER"

# パスワード設定（HOST_PASS が渡された場合のみ）
if [ -n "${HOST_PASS:-}" ]; then
    echo "$USER:$HOST_PASS" | chpasswd
else
    # 未指定時はロック（sudo 不可になる）
    passwd -l "$USER"
fi

# ホームディレクトリの作成とオーナーの変更
mkhomedir_helper "$USER"
chown -R "$USER_ID:$GROUP_ID" /home/"$USER"

# コマンドを指定されたユーザーで実行
cd /home/"$USER"/
gosu "$USER:$USER" /bin/bash

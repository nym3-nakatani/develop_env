#!/bin/bash

# 環境変数からホストのユーザーID、グループID、およびユーザー名を取得
USER_ID=${HOST_UID}
GROUP_ID=${HOST_GID}
USER=${HOST_USER}

# 
if [ $USER_ID -lt 1000 ]; then
    sed -i "/UID_MIN/c UID_MIN   500" /etc/login.defs
    sed -i "/SYS_UID_MAX/c SYS_UID_MAX   499" /etc/login.defs
fi
if [ $GROUP_ID -lt 1000 ]; then
    sed -i "/GID_MIN/c GID_MIN   500" /etc/login.defs
    sed -i "/SYS_GID_MAX/c SYS_GID_MAX   499" /etc/login.defs
fi

# コンテナ内でグループとユーザーを作成
groupadd -g $GROUP_ID $USER
useradd -u $USER_ID -g $GROUP_ID -s /bin/bash -p $(perl -se 'print crypt(${var}, "\$6\$saltsalt")' -- -var=$USER) $USER
usermod -G sudo $USER
# ホームディレクトリの作成とオーナーの変更
mkhomedir_helper $USER
find /etc/skel/ -type f | xargs -I % cp % /home/$USER
chown $USER:$USER /home/$USER
find /home/$USER -maxdepth 1 | xargs chown $USER:$USER

# コマンドを指定されたユーザーで実行
cd /home/$USER/
gosu $USER:$USER "/bin/bash"

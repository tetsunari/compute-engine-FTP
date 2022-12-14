## OS初期設定

Linuxユーザーを作成。
```
useradd hoge
```

ログインパスワードを設定
```
passwd hoge
```

作成ユーザーで`sudo`をパスワードなしで実行可能にする

```
visudo
```

下記の記述を追加

```
hoge    ALL=(ALL)       NOPASSWD: ALL
```

ユーザの切り替え
```
su - hoge
```

gitをインストールする

```
sudo dnf -y update
sudo dnf install -y git-all
```

### Gitの設定を行う

参考：[新しい SSH キーを生成する](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

```
ssh-keygen -t ed25519 -C "hoge@example.com"
```

鍵の作成後にGithubアカウントに対して新しいsshキーを追加する。

[GitHub アカウントへの新しい SSH キーの追加](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

端末のgitを設定する。
```
git config --global user.name "hoge"
git config --global user.email "hoge@example.com"

# editor でvimを指定
git config --global core.editor 'vim -c "set fenc=utf-8"'
```

設定完了後にGithubからリポジトリをpullする。
```
git clone git@github.com:tetsunari/compute-engine-FTP.git
```

### VM起動時にスクリプト実行するように設定(固定グローバルipではないため)
rootユーザーで下記コマンドを実行
```
cat <<EOF >/etc/systemd/system/autorun.service
[Unit]
Description=VM起動時にシェルスクリプト実行
Documentation=
After=network-online.target

[Service]
User=root
ExecStart=/bin/sh /home/lettuce-ftp/lan-tern-pos-ftp/infrastructure/ftp_script.sh
SyslogIdentifier=Diskutilization

[Install]
WantedBy=multi-user.target
EOF
```

### os設定/vsftpdインストール・設定のスクリプトを実行
rootユーザーで下記コマンドを実行
```
sh compute-engine-FTP/ftp_script.sh
```

### vsftpdの設定を行う
rootユーザーで下記コマンドを実行
```
vim /etc/vsftpd/user_list
→hoge-ftp（追加）

mkdir /etc/vsftpd/user_conf

vi /etc/vsftpd/user_conf/hoge-ftp
→local_root=/home/hoge-ftp/ftp_dir(追加)
mkdir /home/hoge-ftp/ftp_dir
```

### hoge-ftpに権限付与
```
chmod 777 /home/hoge-ftp/ftp_dir
```

### 再起動
```
reboot
```

## compute engineの設定
[参考](https://qiita.com/crisaruma/items/14604c0d9c84884675b6)


## SFTP接続設定方法

### 自分のパソコンでssh鍵を作成する
```
ssh-keygen -t rsa -b 4096 -C “hoge-ftp@stage” -f ~/.ssh/stage_sftp_rsa
```
### .pubの内容をcompute engineに記載する

#!/usr/bin/sh

# dnf update
sudo dnf -y update

# selinux disabled
sudo sed -i".org" -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# firewall stop
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service

# timezone
sudo timedatectl set-timezone Asia/Tokyo

# vsftpd install
sudo dnf -y install vsftpd

# 匿名ログイン禁止
sudo sed -i".org" -e "s/^anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd/vsftpd.conf

# メッセージファイルの内容を表示しない
sudo sed -i".org" -e "s/^dirmessage_enable=YES/dirmessage_enable=NO/g" /etc/vsftpd/vsftpd.conf

# ログを保存する
sudo sed -i".org" -e "s/#xferlog_file=\/var\/log\/xferlog/xferlog_file=\/var\/log\/xferlog/g" /etc/vsftpd/vsftpd.conf
sudo sed -i".org" -e "s/^xferlog_std_format=YES/xferlog_std_format=NO/g" /etc/vsftpd/vsftpd.conf

# アスキーモードでの転送を許可
sudo sed -i".org" -e "s/^#ascii_upload_enable=YES/ascii_upload_enable=YES/g" /etc/vsftpd/vsftpd.conf
sudo sed -i".org" -e "s/^#ascii_download_enable=YES/ascii_download_enable=YES/g" /etc/vsftpd/vsftpd.conf

# 設定したlocal_rootより上層ディレクトリへの移動を許可するユーザを設定
sudo sed -i".org" -e "s/^#chroot_local_user=YES/chroot_local_user=YES/g" /etc/vsftpd/vsftpd.conf
sudo sed -i".org" -e "s/^#chroot_list_enable=YES/chroot_list_enable=YES/g" /etc/vsftpd/vsftpd.conf
sudo sed -i".org" -e "s/^#chroot_list_file=\/etc\/vsftpd\/chroot_list/chroot_list_file=\/etc\/vsftpd\/chroot_list/g" /etc/vsftpd/vsftpd.conf

# ディレクトリごと一括での転送有効
sudo sed -i".org" -e "s/^#ls_recurse_enable=YES/ls_recurse_enable=YES/g" /etc/vsftpd/vsftpd.conf

# IPv4 のみをリスンする
sudo sed -i".org" -e "s/^listen=NO/listen=YES/g" /etc/vsftpd/vsftpd.conf

# IPv6 はリスンしない
sudo sed -i".org" -e "s/^listen_ipv6=YES/listen_ipv6=NO/g" /etc/vsftpd/vsftpd.conf

GLOBAL_IP=$(curl inet-ip.info)

sudo sed -i -e "s/^#userlist_deny=NO にすることで、user_list に指定されてるユーザーのみアクセス可//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^userlist_deny=NO//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^userlist_file=\/etc\/vsftpd\/user_list//g" /etc/vsftpd/vsftpd.conf

sudo sed -i -e "s/^#ローカルタイムを使用する//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^use_localtime=YES//g" /etc/vsftpd/vsftpd.conf

sudo sed -i -e "s/^pasv_enable=YES//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^pasv_promiscuous=NO//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^pasv_min_port=61000//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^pasv_max_port=61010//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^pasv_address=${GLOBAL_IP}//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^listen_port=61234//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/^# lettuce-ftpのディレクトリ指定//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/user_config_dir=\/etc\/vsftpd\/user_conf//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "s/allow_writeable_chroot=YES//g" /etc/vsftpd/vsftpd.conf

sudo sed -i -e "s/\n//g" /etc/vsftpd/vsftpd.conf
sudo sed -i -e "/^$/d" /etc/vsftpd/vsftpd.conf

sudo echo "
#userlist_deny=NO にすることで、user_list に指定されてるユーザーのみアクセス可
userlist_deny=NO
userlist_file=/etc/vsftpd/user_list" >> /etc/vsftpd/vsftpd.conf

sudo echo "
#ローカルタイムを使用する
use_localtime=YES" >> /etc/vsftpd/vsftpd.conf

sudo echo "
pasv_enable=YES
pasv_promiscuous=NO
pasv_min_port=61000
pasv_max_port=61010
pasv_address=${GLOBAL_IP}

listen_port=61234
# lettuce-ftpのディレクトリ指定
user_config_dir=/etc/vsftpd/user_conf" >> /etc/vsftpd/vsftpd.conf

sudo echo "
# chroot_list_fileに記載がないユーザでもフォルダに対しの変更を許可する
allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf

# 自動起動の設定をしておく
sudo systemctl enable vsftpd
sudo systemctl enable autorun.service

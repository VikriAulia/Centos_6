#!/bin/bash

# initialisasi var
OS=`uname -p`;
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [ "$ether" = "" ]; then
        ether=eth0
fi
#ether='ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d' | grep -v venet0:';
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";

# go to root
cd

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service sshd restart

# disable ipv6
#echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
#sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
#sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local

# install wget and curl
yum -y install wget curl

# setting repo
wget https://www.dropbox.com/s/7ne1pjq74edbvg4/epel-release-6-8.noarch.rpm
wget https://www.dropbox.com/s/bf58g8ztgcu2lju/remi-release-6.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
rpm -Uvh remi-release-6.rpm

if [ "$OS" == "x86_64" ]; then
  wget https://www.dropbox.com/s/26whkcjyjwq5e4s/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
  rpm -Uvh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
else
  wget https://www.dropbox.com/s/rlzuig8mlkayhk6/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
  rpm -Uvh rpmforge-release-0.5.3-1.el6.rf.i686.rpm
fi

sed -i 's/enabled = 1/enabled = 0/g' /etc/yum.repos.d/rpmforge.repo
sed -i -e "/^\[remi\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/remi.repo
rm -f *.rpm

# remove unused
yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl;
yum -y remove samba

# update
yum -y update

# install webserver
yum -y install nginx php-fpm php-cli
service nginx restart
service php-fpm restart
chkconfig nginx on
chkconfig php-fpm on

# install essential package
yum -y install rrdtool screen iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake

yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar

# matiin exim
service exim stop
chkconfig exim off

# setting vnstat
vnstat -u -i $ether
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
sed -i "s/eth0/$ether/" /etc/sysconfig/vnstat
service vnstat restart
chkconfig vnstat on

# install screenfetch
cd
wget https://github.com/KittyKatt/screenFetch/blob/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# install webserver
cd
wget -O /etc/nginx/nginx.conf "https://github.com/youree82/centos6/raw/master/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Edited By Vikri Aulia. Original By youree82</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://github.com/youree82/centos6/raw/master/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
service php-fpm restart
service nginx restart

# install openvpn
#cd /etc/openvpn/
#wget --no-check-certificate -O ~/easy-rsa.tar.gz https://www.dropbox.com/s/6y3d5qx8kd6l7ah/2.2.2.tar.gz
#tar xzf ~/easy-rsa.tar.gz -C ~/
#mkdir -p /etc/openvpn/easy-rsa/2.0/
#cp ~/easy-rsa-2.2.2/easy-rsa/2.0/* /etc/openvpn/easy-rsa/2.0/
#rm -rf ~/easy-rsa-2.2.2

#cd /etc/openvpn/easy-rsa/2.0/
#cp -u -p openssl-1.0.0.cnf openssl.cnf
#sed -i 's|export KEY_SIZE=1024|export KEY_SIZE=2048|' /etc/openvpn/easy-rsa/2.0/vars
#. /etc/openvpn/easy-rsa/2.0/vars
#. /etc/openvpn/easy-rsa/2.0/clean-all
#export EASY_RSA="${EASY_RSA:-.}"
#"$EASY_RSA/pkitool" --initca $*
#export EASY_RSA="${EASY_RSA:-.}"
#"$EASY_RSA/pkitool" --server server
#export KEY_CN="$CLIENT"
#export EASY_RSA="${EASY_RSA:-.}"
#"$EASY_RSA/pkitool" $CLIENT
#. /etc/openvpn/easy-rsa/2.0/build-dh


#wget -O /etc/openvpn/1194.conf "https://github.com/youree82/centos6/raw/master/1194-centos.conf"
#service openvpn restart
#sysctl -w net.ipv4.ip_forward=1
#sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
#sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

#if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
#      iptables -t nat -A POSTROUTING -o venet0 -j SNAT --to-source $MYIP
#else
#      iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
#fi

##wget -O /etc/iptables.up.rules "https://raw.github.com/yurisshOS/debian7/master/iptables.up.rules"
##sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
##sed -i $MYIP2 /etc/iptables.up.rules;
##iptables-restore < /etc/iptables.up.rules
#service iptables save
#service iptables restart
#chkconfig iptables on
#service openvpn restart

# configure openvpn client config
#cd /etc/openvpn/
#wget -O /etc/openvpn/1194-client.ovpn "https://github.com/youree82/centos6/raw/master/1194-client.conf"
#sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
#echo "<ca>" >> /etc/openvpn/1194-client.ovpn
#cat /etc/openvpn/easy-rsa/2.0/keys/ca.crt >> /etc/openvpn/1194-client.ovpn
#echo -e "</ca>\n" >> /etc/openvpn/1194-client.ovpn
#PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
#useradd -M -s /sbin/nologin youree82
#echo "youree82:$PASS" | chpasswd
#echo "username" >> pass.txt
#echo "password" >> pass.txt
#tar cf client.tar 1194-client.ovpn pass.txt
#cp client.tar /home/vps/public_html/
#cd

# install badvpn
#wget -O /usr/bin/badvpn-udpgw "https://www.dropbox.com/s/ldbjyz71k34jhtw/badvpn-udpgw"
#if [ "$OS" == "x86_64" ]; then
#  wget -O /usr/bin/badvpn-udpgw "https://www.dropbox.com/s/vqsvndls9pzsbo1/badvpn-udpgw64"
#fi
#sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
#sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
#chmod +x /usr/bin/badvpn-udpgw
#screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
#cd /etc/snmp/
#wget -O /etc/snmp/snmpd.conf "https://github.com/youree82/centos6/raw/master/snmpd.conf"
#wget -O /root/mrtg-mem.sh "https://github.com/youree82/centos6/raw/master/mrtg-mem.sh"
#chmod +x /root/mrtg-mem.sh
#service snmpd restart
#chkconfig snmpd on
#snmpwalk -v 1 -c public localhost | tail
#mkdir -p /home/vps/public_html/mrtg
#cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
#curl "https://github.com/youree82/centos6/raw/master/mrtg.conf" >> /etc/mrtg/mrtg.cfg
#sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
#sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
#indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
#echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
#LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
#LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
#LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
#cd

# setting port ssh
echo "Port 143" >> /etc/ssh/sshd_config
echo "Port  22" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 109 -p 110 -p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
echo "/sbin/nologin" >> /etc/shells
service dropbear restart
chkconfig dropbear on

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/eth0/$ether/" config.php
sed -i "s/\$iface_list = array('$ether', 'sixxs');/\$iface_list = array('$ether');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# install squid
#yum -y install squid
#wget -O /etc/squid/squid.conf "https://github.com/youree82/centos6/raw/master/squid-centos.conf"
#sed -i $MYIP2 /etc/squid/squid.conf;
#service squid restart
#chkconfig squid on

# install webmin
cd
wget -O webmin-current.rpm "http://www.webmin.com/download/rpm/webmin-current.rpm"
rpm -Uvh webmin-current.rpm;
rm webmin-current.rpm
service webmin restart
chkconfig webmin on

# install bmon
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/bmon "https://www.dropbox.com/s/cdmi2id7iuowl2j/bmon64"
else
  wget -O /usr/bin/bmon "https://www.dropbox.com/s/gvzmzi4kdgjc0vq/bmon"
fi
chmod +x /usr/bin/bmon

# install PPTP VPN
#yum install -y git
#wget -O vpn-setup-vanilla.sh "https://github.com/youree82/centos6/raw/master/vpn-setup-vanilla.sh"
#bash vpn-setup-vanilla.sh
#iptables -t nat -A POSTROUTING -j SNAT --to-source $MYIP
#service pptpd restart

# download script
cd
wget -O speedtest_cli.py "https://github.com/youree82/centos6/raw/master/speedtest_cli.py"
wget -O bench-network.sh "https://github.com/youree82/centos6/raw/master/bench-network.sh"
wget -O ps_mem.py "https://github.com/youree82/centos6/raw/master/ps_mem.py"
wget -O /usr/bin/user-expire.sh "https://github.com/youree82/centos6/raw/master/user-expire.sh"
wget -O user-list "https://github.com/youree82/centos6/raw/master/user-list"
wget -O user-login.sh "https://github.com/youree82/centos6/raw/master/user-login.sh"
chmod +x speedtest_cli.py
chmod +x bench-network.sh
chmod +x ps_mem.py
chmod +x /usr/bin/user-expire.sh
chmod +x user-list
sed -i 's/auth.log/secure/g' user-login.sh
chmod +x user-login.sh

# cron
echo "0 */6 * * * root reboot" >> /etc/cron.d/reboot
echo "0 0 * * * root user-expire.sh" >> /etc/cron.d/user-expire
service crond start
chkconfig crond on

# limit user 2 bitvise per port
#iptables -A INPUT -p tcp --syn --dport 22 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p tcp --syn --dport 143 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p tcp --syn --dport 109 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p tcp --syn --dport 110 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p tcp --syn --dport 1194 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p tcp --syn --dport 7300 -m connlimit --connlimit-above 2 -j REJECT
#iptables -A INPUT -p udp --syn --dport 7300 -m connlimit --connlimit-above 2 -j REJECT
#iptables-save > /etc/iptables.up.rules
#chkconfig iptables on

# finalisasi
chown -R nginx:nginx /home/vps/public_html
service nginx restart
service php-fpm restart
service vnstat restart
service openvpn restart
chkconfig openvpn on
service snmpd restart
service sshd restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart
service pptpd restart
service crond restart

#service nginx start
#service php-fpm start
#service vnstat restart
#service snmpd restart
#service sshd restart
#service dropbear restart
#service fail2ban restart
#service webmin restart
#service crond start
#service squid start
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenSSH  : 22, 143"  | tee -a log-install.txt
echo "Dropbear : 109, 110, 443"  | tee -a log-install.txt
echo "OpenVPN  : 1194 (client config : http://$MYIP:81/client.tar)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "PPTP VPN  : Create User via Putty (echo "username pptpd password *" >> /etc/ppp/chap-secrets)"  | tee -a log-install.txt
echo "Squid    : 80, 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Tools"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, nethogs"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "screenfetch"  | tee -a log-install.txt
echo "./ps_mem.py (Cek RAM)"  | tee -a log-install.txt
echo "./speedtest_cli.py --share (Speed Test VPS)"  | tee -a log-install.txt
echo "./bench-network.sh (Cek Kualitas VPS)"  | tee -a log-install.txt
echo "user-expired.sh (Auto Lock User Expire tiap jam 00:00)"  | tee -a log-install.txt
echo "./user-list (Melihat Daftar User)"  | tee -a log-install.txt
echo "./user-login.sh (Monitoring User Login Dropbear, OpenSSH dan PPTP VPN)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP:81/vnstat/ (Cek Bandwith)"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo "Autolimit 2 bitvise per IP to all port (port 22, 143, 109, 110, 443, 1194, 7300 TCP/UDP)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script Modified by Yuri Bhuana (fb.com/youree82, 0858 1500 2021)"  | tee -a log-install.txt
echo "Thanks to Original Creator Kang Arie & Mikodemos" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "VPS AUTO REBOOT TIAP 6 JAM, SILAHKAN REBOOT VPS ANDA !"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt

# Centos_6

#List Service:
nginx;
php5-fpm;
mariadb 10;
screenfetch;
webmin;
vnstat;
fail2ban;
dropbear;

# Include Script
./ps_mem.py (Cek RAM);
./speedtest_cli.py --share (Speed Test VPS);
./bench-network.sh (Cek Kualitas VPS);
./user-expired.sh (Auto Lock User Expire tiap jam 00:00);
./user-list (Melihat Daftar User);
./user-login.sh (Monitoring User Login Dropbear, OpenSSH dan PPTP VPN);

#In Process 
MRTG + MIBS;
phpmyadmin;
ftp;

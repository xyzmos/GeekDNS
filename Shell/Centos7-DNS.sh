#!/bin/bash
echo "此脚本为GeekDNS Centos7搭建脚本"
echo "搭建前请确认环境是干净的，将使用50，853，8053，9090端口"
echo "https://www.4gml.com"

echo "下面开始搭建"
echo "请输入SSL证书路径地址："
read SSLCert
if [[ -z $SSLCert ]]
	then
	SSLCert=123
fi
echo "请输入SSL密钥路径地址："
read SSLKey
if [[ -z $SSLKey ]]
	then
	SSLKey=123
fi

echo "是否具有IPV6网络（Y/N）："
read IPV6
if [[ -z $IPV6 ]]
	then
	IPV6=N
fi

echo "是否为国外服务器（Y/N）："
read Other
if [[ -z $Other ]]
	then
	Other=N
fi

echo "安装依赖包，不要乱动，别按回车"
yum clean all
yum makecache
yum update -y
#安装环境
yum install -y crontabs
mkdir -p /var/spool/cron/
yum install -y wget gcc tar zip redhat-lsb gawk unzip net-tools psmisc glibc-static expect telnet
yum install -y openssl openssl-devel lzo lzo-devel pam pam-devel automake
yum install -y autoconf libtool make build-essential curl curl-devel zlib-devel perl perl-devel perl-core cpio expat-devel gettext-devel git asciidoc xmlto
yum -y install epel-release bind-util libevent libevent-devel
yum install python-setuptools -y && easy_install pip
yum install python-devel libffi-devel -y
yum group install 'Development Tools' -y

echo -e "同步时间为上海时区"
\cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum install ntpdate -y
echo -e "向苹果NTP服务器同步时间"
ntpdate -u time.apple.com
hwclock --systohc
systemctl start ntpd.service
service ntpd start
echo -e "时间同步完毕..."

echo "安装libsodium加密支持库"
cd /root
wget -N --no-check-certificate https://download.233py.com/dns/soft/libsodium-1.0.18.tar.gz
tar xf libsodium-1.0.18.tar.gz && cd libsodium-1.0.18
./configure && make -j2 && make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig
rm -rf ../libsodium-1.0.18*

#升级openssl
echo "正在升级OpenSSL版本"
cd /root
wget https://download.233py.com/dns/soft/OpenSSL_1_1_1d.tar.gz
tar -xzf OpenSSL_1_1_1d.tar.gz && rm -rf OpenSSL_1_1_1d.tar.gz
rm -rf OpenSSL_1_1_1d.tar.gz && cd openssl-OpenSSL_1_1_1d
./config --prefix=/usr
make && make install
ldconfig
rm -rf ../openssl*
cd

echo "安装DNSDIST"
yum install epel-release yum-plugin-priorities -y
curl -o /etc/yum.repos.d/powerdns-dnsdist-14.repo https://repo.powerdns.com/repo-files/centos-dnsdist-14.repo
yum install dnsdist -y
mkdir /etc/dnsdist
curl -o /etc/dnsdist/dnsdist.conf https://download.233py.com/dns/conf/dnsdist.conf
echo "DNSDIST安装完成"

echo "开始安装GO"
wget https://studygolang.com/dl/golang/go1.13.7.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.13.7.linux-amd64.tar.gz && rm -rf go1.13.7.linux-amd64.tar.gz
mkdir -p /root/go
echo 'export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/root/go' >> /etc/profile
source /etc/profile
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
echo "安装GO完成"

echo "开始安装DOH Server"
cd /root
wget https://download.233py.com/dns/soft/dns-over-https.tar.gz
tar -zxvf dns-over-https.tar.gz && rm -rf dns-over-https.tar.gz
cd dns-over-https
make && make install
systemctl start doh-server.service
systemctl enable doh-server.service

echo "正在安装Unbound"
wget https://download.233py.com/dns/soft/unbound-1.9.6.tar.gz
tar -zxvf unbound-1.9.6.tar.gz && rm -rf unbound-1.9.6.tar.gz && cd unbound-1.9.6
./configure --enable-subnet --with-libevent --with-pthreads --with-ssl --enable-dnscrypt
make && sudo make install
curl -o /usr/local/etc/unbound/root.hints ftp://ftp.internic.net/domain/named.cache
/sbin/ldconfig -v
unbound-anchor
# 下载新的配置文件
curl -o /usr/local/etc/unbound/unbound.conf https://download.233py.com/dns/conf/unbound.conf
if [[ $Other == Y ]]
then
	curl -o /usr/local/etc/unbound/unbound.conf https://download.233py.com/dns/conf/unbounds.conf
fi
# 是否开启IPV6 
if [[ $IPV6 == Y ]]
then
	sed -i "s/do-ip6: no/do-ip6: yes/g" /usr/local/etc/unbound/unbound.conf
fi

# 更新证书路径 和 线程数
#CPU 核心数储存
CPU_NUM=`cat /proc/cpuinfo |grep "processor"|wc -l`
sed -i "s/CPUNUM/$CPU_NUM/g" /usr/local/etc/unbound/unbound.conf
sed -i "s:TLSKEY:$SSLKey:g" /usr/local/etc/unbound/unbound.conf
sed -i "s:TLSCERT:$SSLCert:g" /usr/local/etc/unbound/unbound.conf
echo "安装守护进程守护dnsdist"
pip install supervisor
rm -rf /etc/supervisord.conf
curl -o /etc/supervisord.conf https://download.233py.com/dns/conf/supervisord.conf
mkdir /etc/unbound
# 定时更新配置文件
#重启命令
curl -o /bin/UPDNS https://download.233py.com/dns/shell/UPDNS
curl -o /bin/CKDNS https://download.233py.com/dns/shell/CKDNS
chmod 777 /bin/UPDNS
chmod 777 /bin/CKDNS

# 第一次初始化配置文件
echo "初始化配置信息"
UPDNS

#防火墙
echo "配置防火墙"
firewall-cmd --permanent --zone=public --add-port=853/tcp
firewall-cmd --permanent --zone=public --add-port=53/tcp
firewall-cmd --permanent --zone=public --add-port=53/udp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=9090/udp
firewall-cmd --permanent --zone=public --add-port=9090/tcp
firewall-cmd --reload
setenforce 0
echo "/usr/sbin/setenforce 0" >> /etc/rc.local
echo "0 0 * * * UPDNS">>/var/spool/cron/root
echo "* * * * * CKDNS">>/var/spool/cron/root
systemctl restart crond.service >/dev/null 2>&1   
systemctl enable crond.service >/dev/null 2>&1

echo "安装完成，请参考https://www.4gml.com配置Nginx"


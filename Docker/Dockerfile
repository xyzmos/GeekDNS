FROM archlinux:latest
CMD ["/usr/sbin/init"]
ENV foreign no
ADD data /root/tmp
RUN echo 'Server = https://mirrors.huaweicloud.com/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist \
    && echo -e "\n[archlinuxcn]\nSigLevel = TrustAll\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch\n\n[antergos]\nSigLevel = TrustAll\nServer = https://mirrors.tuna.tsinghua.edu.cn/antergos/\$repo/\$arch\n" | tee -a /etc/pacman.conf \
    && pacman -Syyuu --noconfirm \
    && pacman -S archlinuxcn-keyring antergos-keyring --noconfirm \
    && pacman -S psmisc supervisor caddy cron git make cmake libsodium net-tools openssl base-devel go gcc libevent --noconfirm \
    && \cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir ~/gopath && export GOPATH=~/gopath && source /etc/profile && go env -w GO111MODULE=on && go env -w GOPROXY=https://goproxy.cn,direct \
    && cd /root/tmp/dns-over-https && make && make install && \cp -rf /root/tmp/conf/doh-server.conf /etc/dns-over-https/doh-server.conf \
    && cd /root/tmp/unbound && ./configure --enable-subnet --with-libevent --with-pthreads --with-ssl --enable-dnscrypt && make && make install  \
    && \cp -rf /root/tmp/conf/unbound/* /usr/local/etc/unbound && /sbin/ldconfig -v \
    && mkdir /etc/unbound&& \cp -rf /root/tmp/shell/UPDNS /bin/UPDNS && \cp -rf /root/tmp/shell/CKDNS /bin/CKDNS && chmod 777 /bin/UPDNS && chmod 777 /bin/CKDNS
RUN ["/bin/bash", "-c", "bash /root/tmp/install.sh"]
EXPOSE 53
EXPOSE 8053
EXPOSE 853
EXPOSE 2015
ENTRYPOINT /root/tmp/entrypoint.sh

#!/bin/bash
unbound-anchor
echo "0 0 * * * UPDNS" >> /var/spool/cron/root
echo "* * * * * CKDNS" >> /var/spool/cron/root
cp /root/tmp/conf/caddy.conf /etc/caddy/caddy.conf
cp /root/tmp/conf/supervisord.conf /etc/supervisord.conf
pacman -Scc --noconfirm
journalctl --vacuum-size=50M


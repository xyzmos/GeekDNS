# GeekDNS
官网：https://www.233py.com

目的仅用于科研用途、保护隐私、最主要用于防止运营商DNS劫持～  
主要采用Unbound + DOH Server + DNSDIST   

 - Unbound: https://nlnetlabs.nl/projects/unbound/about  
 - DOH Server: https://github.com/m13253/dns-over-https  
 - DNSDIST:  https://dnsdist.org  

# 搭建教程
https://www.4gml.com/forum-7.htm  

## 搭建脚本
此脚本自动配置安装Unbound， DOH Server，Dnsdist，安装完成后将存在以下服务
- TCP 853：DNS Over TLS  
- TCP&&UDP 9090,53：普通DNS (DNSDIST)  
- TCP 8053：DOH Server (https 实现需要配置nginx实现)  


#### Centos 7：
``` bash
wget https://raw.githubusercontent.com/xyzmos/GeekDNS/master/Shell/Centos7-DNS.sh && bash Centos7-DNS.sh 
```
#### Centos 8：
``` bash
wget https://raw.githubusercontent.com/xyzmos/GeekDNS/master/Shell/Centos8-DNS.sh && bash Centos8-DNS.sh 
```
#### Debian 10：
``` bash
wget https://raw.githubusercontent.com/xyzmos/GeekDNS/master/Shell/Debian10-DNS.sh && bash Debian10-DNS.sh 
```
#### Ubuntu 18.04：
``` bash
wget https://raw.githubusercontent.com/xyzmos/GeekDNS/master/Shell/Ubuntu18.04-DNS.sh && bash Ubuntu18.04-DNS.sh 
```



### Nginx 配置
``` nginx
 location /dns-query {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 86400;
    proxy_pass http://127.0.0.1:8053/dns-query;
}
```


## 架构  
### Unbound 
Unbound负责解析、缓、转发查询、 DNS-OVER-TLS  
### DOH Server 
提供 DNS-OVER-HTTP 服务   
### DNSDIST 
负责DNSCrypt 以及 UDP + TCP，可用于实现负载均衡和限制QPS·「配置文件没限制，请参考官方文档」   
### NGINX 
将DNS-OVER-HTTP转DNS-OVER-HTTPS  

## QS  
### 1、关于 Unbound 里面引入的配置文件：
#### -  insecure.conf
  因为国内网络环境问题，当你验证某些域名的DNSSEC时会被干扰，无法验证，所以该部分域名需要排除DNSSEC验证。  

#### -  forward.conf
  用于解决域名污染问题，向海外上游转发信息。海外上游你可以自行指定，目前该文件里的上游为采用DOT方式向海外上游查询。  

#### -  domestic.conf
  用于解决阿里高防DNS解析问题，以及解决部分服务比如bilibili，QQ，等服务的CDN调度问题。
  此配置文件采用DNS派提供的DNS（介意的请更换其他支持ECS的国内DNS）  


### 2、关于上述配置文件更新、
此配置文件每天凌晨1:30会自动更新。
#### -  方式一：采用Shell/OtherShell/UPDNS脚本进行更新
#### -  方式二：自行下载替换
转发域名列表：https://download.233py.com/dns/update/forward.conf  
取消验证列表：https://download.233py.com/dns/update/insecure.conf  
交付域名列表：https://download.233py.com/dns/update/domestic.conf  
#### 定时执行
``` bash
curl -o /etc/unbound/forward.conf https://download.233py.com/dns/update/forward.conf
curl -o /etc/unbound/domestic.conf https://download.233py.com/dns/update/domestic.conf
curl -o /etc/unbound/insecure.conf https://download.233py.com/dns/update/insecure.conf
```

### 引用信息列表：
DNS派： http://www.dnspai.com/public.html  


这里是GeekDNS配置文件
更新时间2020/2/14
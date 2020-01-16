# GeekDNS
官网：https://www.233py.com

目的仅用于科研用途、保护隐私、最主要用于防止运营商DNS劫持～  
主要采用Unbound + DOH Server + DNSDIST   
 - Unbound: https://nlnetlabs.nl/projects/unbound/about/  
 - DOH Serve:r https://github.com/m13253/dns-over-https  
 - DNSDIST:  https://dnsdist.org/  

# 搭建教程
https://www.4gml.com/forum-7.htm  


## 架构  
### Unbound 
Unbound负责解析、缓、转发查询、 DNS-OVER-TLS  
### DOH Server 
提供 DNS-OVER-HTTPS 服务  
### DNSDIST 
负责DNSCrypt 以及 UDP + TCP，可用于实现负载均衡和限制QPS·「配置文件没限制，请参考官方文档」  

## QS  
### 1、关于 Unbound 里面引入的配置文件：
#### -  insecure.conf
  因为国内网络环境问题，当你验证某些域名的DNSSEC时会被干扰，无法验证，所以该部分域名需要排除DNSSEC验证。  

#### -  forward.conf
  用于解决域名污染问题，向海外上游转发信息。海外上游你可以自行指定，目前该文件里的上游为采用DOT方式**GEEKDNS**海外上游查询。  

#### -  domestic.conf
  用于解决阿里高防DNS解析问题，以及解决部分服务比如bilibili，QQ，等服务的CDN调度问题。
  此配置文件采用DNS派提供的DNS（介意的请更换其他支持ECS的国内DNS）  

  ##### 已知：
  **119.29.29.29**  存在无法转发问题或者服务不稳定。  
  **8.8.8.8** 存在解析结果CDN调度问题，和服务的不稳定。  
  **百度，114，阿里**等服务不支持传入Subnet。  


### 2、关于上述配置文件更新、
此配置文件每天凌晨1:30会自动更新。
#### -  方式一：采用Config/Shell/Update.py 脚本进行更新
#### -  方式二：自行下载替换
转发域名列表：https://api.nextrt.com/api/dns/forward  
取消验证列表：https://api.nextrt.com/api/dns/insecure  
交付域名列表：https://api.nextrt.com/api/dns/domestic  

### 引用信息列表：
DNS派： http://www.dnspai.com/public.html  


这里是GeekDNS配置文件
更新时间2020/1/16
# GeekDNS

主要采用Unbound + DOH Server + DNSDIST   
https://nlnetlabs.nl/projects/unbound/about/  
https://github.com/m13253/dns-over-https  

## 架构  
### Unbound 
Unbound负责解析,与转发查询
### DOH Server 
提供 DNS-OVER-HTTPS 服务
### DNSDIST 
负责DNSCrypt 和 DNS-OVER-TLS 以及 UDP + TCP，可用于实现负载均衡和限制QPS·「配置文件没限制，请参考官方文档」  

## QS  
### 关于国内 Unbound：
insecure.conf-因为国内网络问题，当你验证某些域名的dnssec时会被阻断，无法验证，所以该部分域名需要排除DNSSEC验证。  
gfwlist.conf-看名字   
domain.conf-阿里云层高防DNS 对传入ECS会拒绝解析。



这里是GeekDNS配置文件
更新时间2019/2/24

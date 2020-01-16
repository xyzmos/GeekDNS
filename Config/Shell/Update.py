#!/usr/bin/env python  
#coding=utf-8
 
import urllib2
import re
import os
import datetime
import ssl

baseurl = 'https://api.nextrt.com'

forwardfile = '/etc/unbound/forward.conf'
domesticfile = '/etc/unbound/domestic.conf'
insecurefile = '/etc/unbound/insecure.conf'

if hasattr(ssl, '_create_unverified_context'):
	ssl._create_default_https_context = ssl._create_unverified_context
content = urllib2.urlopen(baseurl + '/api/dns/forward', timeout=35).read()

tfs = open(forwardfile, 'w')
tfs.write(content)
tfs.close()

if hasattr(ssl, '_create_unverified_context'):
	ssl._create_default_https_context = ssl._create_unverified_context
content = urllib2.urlopen(baseurl + '/api/dns/domestic', timeout=35).read()

tfs = open(domesticfile, 'w')
tfs.write(content)
tfs.close()

if hasattr(ssl, '_create_unverified_context'):
	ssl._create_default_https_context = ssl._create_unverified_context
content = urllib2.urlopen(baseurl + '/api/dns/insecure', timeout=35).read()

tfs = open(insecurefile, 'w')
tfs.write(content)
tfs.close()

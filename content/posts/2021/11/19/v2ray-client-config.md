---
date: "2021-11-19T00:00:00Z"
description: v2ray 配置
image: topic/pandalisa.png
keywords: v2ray
tags:
- v2ray
title: v2ray 配置
typora-root-url: ../../
---

#  v2ray 配置



## 命令行快捷键

```
pxy='http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 $@'
```



## client.json

同时监听 `socks5` 和 `http`

```json
{
  "log": {
    "error": "",
    "loglevel": "info",
    "access": ""
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "udp": false,
        "auth": "noauth"
      },
      "port": "7890"
    },
    {
      "listen": "127.0.0.1",
      "protocol": "http",
      "settings": {
        "timeout": 360
      },
      "port": "7891"
    }
  ],
  "outbounds": [
    {
      "protocol": "shadowsocks",
      "streamSettings": {
        "tcpSettings": {
          "header": {
            "type": "none"
          }
        },
        "tlsSettings": {
          "allowInsecure": true
        },
        "security": "none",
        "network": "tcp"
      },
      "tag": "proxy",
      "settings": {
        "servers": [
          {
            "port": 123123,
            "method": "cipher-method",
            "password": "your-password",
            "address": "your-hosts",
            "level": 0,
            "email": "",
            "ota": false
          }
        ]
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIP",
        "redirect": "",
        "userLevel": 0
      }
    },
    {
      "tag": "block",
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "none"
        }
      }
    }
  ],
  "dns": {},
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [
      {
        "type": "field",
        "outboundTag": "direct",
        "domain": [
          "geosite:cn"
        ] // china site
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "ip": [
          "geoip:cn", // china ip
          "geoip:private" // private ip
        ]
      }
    ]
  },
  "transport": {}
}
```



## server.json

```json
{
  "inbounds": [
    {
      "port": 123123,
      "protocol": "shadowsocks",
      "settings": {
        "email": "love@v2ray.com",
        "method": "cypher-method",
        "password": "your-password",
        "level": 0,
        "ota": true,
        "network": "tcp"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
```


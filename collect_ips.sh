#!/bin/bash
echo "🌐 正在获取 Cloudflare IPv4 列表..."
CF_IPS=$(curl -s https://www.cloudflare.com/ips-v4)

echo "🔍 扫描所有 IP 国家归属并生成国家分类 JSON..."
mkdir -p ip-json
> all_ips.txt

for ip in $CF_IPS; do
  echo "$ip" >> all_ips.txt
  while IFS= read -r address; do
    ip_addr=$(echo "$address" | cut -d '/' -f 1)

    result=$(curl -s "https://ipinfo.io/${ip_addr}/json?token=${IPINFO_TOKEN}")
    country=$(echo "$result" | jq -r '.country // empty')

    if [[ -n "$country" ]]; then
      echo "{\"ip\": \"${ip_addr}\"}" >> "ip-json/${country}.json"
      echo "✅ 归类成功国家: ${country} IP: ${ip_addr}"
    else
      echo "❌ 无法识别国家: $ip"
    fi
  done < <(prips "$ip")
done

echo "📦 所有国家优选 IP 已生成于 ip-json 目录"

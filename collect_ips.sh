#!/bin/bash
set -e

echo "📥 开始抓取多个 IP 来源..."

# 创建临时文件
TMP_IP_LIST="all_ips.txt"
> "$TMP_IP_LIST"

# 源地址列表
URLS=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.vvhan.com/"
  "https://cf.090227.xyz"
  "https://stock.hostmonit.com/CloudFlareYes"
)

# 抓取
for url in "${URLS[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$TMP_IP_LIST" || true
done

# 去重
sort -u "$TMP_IP_LIST" -o "$TMP_IP_LIST"

echo "🌍 开始根据国家分类 IP 地址..."

mkdir -p ip-json
declare -A ip_map

while read -r ip; do
  country=$(curl -s "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" | grep country | cut -d '"' -f4)
  if [[ -n "$country" ]]; then
    echo "🔍 IP: $ip => 国家: $country"
    ip_map["$country"]+="$ip\n"
  fi
done < "$TMP_IP_LIST"

# 写入各个国家的文件
for country in "${!ip_map[@]}"; do
  file="ip-json/${country}.json"
  echo -e "${ip_map[$country]}" | sort -u > "$file"
  echo "✅ 写入 $file"
done

echo "🎉 所有 IP 收集与分类完成"

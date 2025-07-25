#!/bin/bash

set -e

echo "📥 开始抓取多个 IP 来源..."

SOURCES=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.090227.xyz"
  "https://cf.vvhan.com/"
  "https://stock.hostmonit.com/CloudFlareYes"
)

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
TMP_IP_FILE="$WORKDIR/all_ips.txt"
JSON_DIR="$WORKDIR/ip-json"
mkdir -p "$JSON_DIR"
> "$TMP_IP_FILE"

# 抓取并提取IP
for url in "${SOURCES[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$TMP_IP_FILE"
done

echo "🌍 开始根据国家分类 IP 地址..."

# 初始化数组
declare -A ip_by_country

# 遍历IP地址
while read -r ip; do
  [[ -z "$ip" ]] && continue
  country=$(curl -s "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" | grep '"country"' | cut -d '"' -f 4)
  [[ -z "$country" ]] && continue
  echo "🔍 IP: $ip => 国家: $country"
  ip_by_country["$country"]+="$ip"$'\n'
done < "$TMP_IP_FILE"

# 写入 JSON 文件
for country in "${!ip_by_country[@]}"; do
  json_file="${JSON_DIR}/${country}.json"
  echo "✅ 写入 $json_file"
  printf '%s' "${ip_by_country[$country]}" | jq -R . | jq -s . > "$json_file"
done

echo "🎉 IP 收集完成。"

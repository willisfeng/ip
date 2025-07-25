#!/bin/bash
set -e

echo "📥 开始抓取多个 IP 来源..."

URLS=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.090227.xyz"
  "https://cf.vvhan.com/"
  "https://stock.hostmonit.com/CloudFlareYes"
)

TMP_IP_FILE="all_ips.txt"
IP_JSON_DIR="ip-json"
mkdir -p "$IP_JSON_DIR"

rm -f "$TMP_IP_FILE"

for url in "${URLS[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$TMP_IP_FILE" || true
done

sort -u "$TMP_IP_FILE" -o "$TMP_IP_FILE"

echo "🌍 开始根据国家分类 IP 地址..."

if [ -z "$IPINFO_TOKEN" ]; then
  echo "❌ 未设置 IPINFO_TOKEN"
  exit 1
fi

while read -r ip; do
  country=$(curl -s "https://ipinfo.io/$ip?token=$IPINFO_TOKEN" | grep country | cut -d '"' -f 4)

  if [[ -z "$country" ]]; then
    echo "⚠️ 无法识别国家: $ip"
    continue
  fi

  echo "🔍 IP: $ip => 国家: $country"

  json_file="$IP_JSON_DIR/${country}.json"

  # 如果文件不存在，初始化为空数组
  if [ ! -f "$json_file" ]; then
    echo "[]" > "$json_file"
  fi

  # 读取现有内容并合并新 IP，再去重
  updated=$(jq -c --arg ip "$ip" 'if . | index($ip) then . else . + [$ip] | unique end' "$json_file")
  echo "$updated" > "$json_file"

done < "$TMP_IP_FILE"

echo "🎉 所有 IP 收集与分类完成"


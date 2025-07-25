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

# 清理旧文件
rm -f "$TMP_IP_FILE"

# 抓取 IP 地址
for url in "${URLS[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$TMP_IP_FILE" || true
done

# 去重
sort -u "$TMP_IP_FILE" -o "$TMP_IP_FILE"

echo "🌍 开始根据国家分类 IP 地址..."

# 检查 IPINFO_TOKEN 是否设置
if [ -z "$IPINFO_TOKEN" ]; then
  echo "❌ 未设置 IPINFO_TOKEN"
  exit 1
fi

# 声明国家-IP映射（兼容非bash环境）
> /tmp/unique_countries.txt

while read -r ip; do
  country=$(curl -s "https://ipinfo.io/$ip?token=$IPINFO_TOKEN" | grep country | cut -d '"' -f 4)

  if [[ -z "$country" ]]; then
    echo "⚠️ 无法识别国家: $ip"
    continue
  fi

  echo "🔍 IP: $ip => 国家: $country"
  echo "$ip" >> "$IP_JSON_DIR/${country}.json"
done < "$TMP_IP_FILE"

echo "🧹 去重每个国家文件中的 IP..."
for file in "$IP_JSON_DIR"/*.json; do
  sort -u "$file" -o "$file"
  echo "✅ 写入 $(basename "$file")"
done

echo "🎉 所有 IP 收集与分类完成"

#!/bin/bash

set -e

# === 初始化变量 ===
OUTPUT_DIR="ip-json"
IP_FILE="all_ips.txt"
IP_SOURCES=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.vvhan.com/"
  "https://cf.090227.xyz"
  "https://stock.hostmonit.com/CloudFlareYes"
)

echo "📥 开始抓取多个 IP 来源..."
> "$IP_FILE"  # 清空旧文件

for URL in "${IP_SOURCES[@]}"; do
  echo "🔗 抓取：$URL"
  curl -s "$URL" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' >> "$IP_FILE" || echo "⚠️ 抓取失败：$URL"
done

# 去重
sort -u "$IP_FILE" -o "$IP_FILE"

echo "🌍 开始根据国家分类 IP 地址..."
mkdir -p "$OUTPUT_DIR"

# 判断 jq 是否安装
if ! command -v jq &> /dev/null; then
  echo "🔧 安装 jq..."
  sudo apt-get update && sudo apt-get install -y jq
fi

# 清空原有 json 文件（防止累积）
rm -f "$OUTPUT_DIR"/*.json

# 逐个 IP 查询国家
while read -r ip; do
  country=$(curl -s "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" | jq -r .country)
  country=${country:-"UNKNOWN"}

  echo "🔍 IP: $ip => 国家: $country"
  echo "\"$ip\"" >> "$OUTPUT_DIR/${country}.json"
done < "$IP_FILE"

# 整理每个 json 文件为合法数组格式
for file in "$OUTPUT_DIR"/*.json; do
  jq -Rn '[inputs]' "$file" > tmp.json && mv tmp.json "$file"
  echo "✅ 写入 $file"
done

echo "🎉 所有 IP 收集与分类完成"

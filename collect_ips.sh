#!/bin/bash
set -e

echo "📥 开始抓取多个 IP 来源..."

# 多个IP来源链接
SOURCES=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.090227.xyz"
  "https://cf.vvhan.com/"
  "https://stock.hostmonit.com/CloudFlareYes"
)

TMP_ALL_IPS="all_ips.txt"
OUTPUT_DIR="ip-json"

# 清理旧文件
rm -f "$TMP_ALL_IPS"
mkdir -p "$OUTPUT_DIR"

# 抓取 IP
for URL in "${SOURCES[@]}"; do
  echo "🔗 抓取：$URL"
  curl -s "$URL" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' >> "$TMP_ALL_IPS" || echo "⚠️ 抓取失败：$URL"
done

# 去重
sort -u "$TMP_ALL_IPS" -o "$TMP_ALL_IPS"

echo "🌍 开始根据国家分类 IP 地址..."
> "${OUTPUT_DIR}/US.json"
> "${OUTPUT_DIR}/CN.json"

while IFS= read -r ip; do
  country=$(curl -s "https://ipinfo.io/$ip?token=${IPINFO_TOKEN}" | grep -oP '"country":\s*"\K[A-Z]+')

  if [[ $country ]]; then
    echo "🔍 IP: $ip => 国家: $country"
    echo "\"$ip\"," >> "${OUTPUT_DIR}/${country}.json"
  fi
done < "$TMP_ALL_IPS"

# 美化每个 json 文件
for file in ${OUTPUT_DIR}/*.json; do
  jq -s '.' "$file" > tmp.json && mv tmp.json "$file"
  echo "✅ 写入 $file"
done

echo "🎉 所有 IP 收集与分类完成"

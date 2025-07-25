#!/bin/bash

CF_IP_SOURCE="https://www.cloudflare.com/ips-v4"
IP_TMP_FILE="all_ips.txt"
OUTPUT_DIR="ip-json"
TOKEN="${IPINFO_TOKEN}"

mkdir -p "$OUTPUT_DIR"
curl -s "$CF_IP_SOURCE" -o "$IP_TMP_FILE"

echo "🌍 正在按国家整理 IP..."

# 清理旧数据
rm -f "$OUTPUT_DIR"/*.json

# 创建临时映射
declare -A country_map

while read ip; do
  echo "查询IP: $ip"
  info=$(curl -s "https://ipinfo.io/${ip}?token=${TOKEN}")
  echo "返回: $info"

  country=$(echo "$info" | jq -r '.country // "ZZ"')

  if [[ $country != "ZZ" ]]; then
    country_map[$country]="${country_map[$country]}\"$ip\",\n"
  else
    echo "⚠️ 无法识别国家: $ip"
  fi
done < "$IP_TMP_FILE"

# 保存为 JSON 文件
for code in "${!country_map[@]}"; do
  echo -e "[\n${country_map[$code]%??}\n]" > "${OUTPUT_DIR}/${code}.json"
done

echo "✅ 分类完成，已保存至 $OUTPUT_DIR 目录。"

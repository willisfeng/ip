#!/bin/bash

echo "📥 开始抓取多个 IP 来源..."

# 创建临时工作目录
WORKDIR=$(mktemp -d)
IP_FILE="$WORKDIR/all_ips.txt"
> "$IP_FILE"

# 抓取页面数据
URLS=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.vvhan.com/"
  "https://cf.090227.xyz"
  "https://stock.hostmonit.com/CloudFlareYes"
)

for URL in "${URLS[@]}"; do
  echo "🔗 抓取：$URL"
  curl -s "$URL" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$IP_FILE"
done

# 去重
sort -u "$IP_FILE" -o "$IP_FILE"

echo "🌍 开始根据国家分类 IP 地址..."

# 创建输出目录
OUT_DIR="ip-json"
mkdir -p "$OUT_DIR"

# 循环查询IP归属国家并写入对应json
while read -r ip; do
  country=$(curl -s "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" | jq -r .country)
  [[ "$country" == "null" || -z "$country" ]] && continue

  echo "🔍 IP: $ip => 国家: $country"

  JSON_FILE="$OUT_DIR/${country}.json"

  # 如果目标文件已存在，先读取旧数据合并后写入
  if [[ -f "$JSON_FILE" ]]; then
    jq -s 'add | unique' <(jq -c . "$JSON_FILE") <(echo "[\"$ip\"]") > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "$JSON_FILE"
  else
    echo "[\"$ip\"]" > "$JSON_FILE"
  fi
done < "$IP_FILE"

echo "🎉 所有 IP 收集与分类完成"

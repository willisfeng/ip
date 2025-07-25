#!/bin/bash

echo "📥 开始抓取多个 IP 来源..."

# IP 源网站
urls=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
)

# 清空旧数据
> all_ips.txt

# 抓取所有源数据
for url in "${urls[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' >> all_ips.txt
done

# 去重
sort -u all_ips.txt -o all_ips.txt

echo "🌍 开始根据国家分类 IP 地址..."

mkdir -p ip-json
rm -f ip-json/*.json

declare -A country_ips

while read -r ip; do
  country=$(curl -s "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" | grep '"country"' | cut -d '"' -f 4)
  echo "🔍 IP: $ip => 国家: $country"
  [ -n "$country" ] && echo "\"$ip\"," >> "ip-json/${country}.json"
done < all_ips.txt

# 去除 JSON 尾逗号
for file in ip-json/*.json; do
  sed -i '$ s/,$//' "$file"
  sed -i '1s/^/[\n/' "$file"
  echo "]" >> "$file"
done

echo "🎉 IP 收集完成。"

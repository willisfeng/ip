#!/bin/bash

set -e

echo "📥 开始抓取多个 IP 来源..."

# 数据来源
sources=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.vvhan.com/"
  "https://cf.090227.xyz"
  "https://stock.hostmonit.com/CloudFlareYes"
)

# 临时文件夹
tmp_dir=$(mktemp -d)
ip_file="$tmp_dir/ips.txt"
> "$ip_file"

# 抓取 IP 数据
for url in "${sources[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$ip_file" || true
done

# 去重
sort -u "$ip_file" > "$tmp_dir/all_ips.txt"

echo "🌍 开始根据国家分类 IP 地址..."

# 准备输出目录
mkdir -p ip-json
> ip-json/US.json

# 获取国家归属（仅识别 US）
while IFS= read -r ip; do
  country=$(curl -s ipinfo.io/$ip?token=${IPINFO_TOKEN} | jq -r .country)
  if [[ "$country" == "US" ]]; then
    echo "🔍 IP: $ip => 国家: $country"
    echo "\"$ip\"," >> ip-json/US.json
  fi
done < "$tmp_dir/all_ips.txt"

# 修正 JSON 格式
sed -i '1s/^/[\n/' ip-json/US.json
sed -i '$s/,$/\n]/' ip-json/US.json




echo "🎉 IP 已根据国家分类保存至 ip-json 文件夹内。"

echo "// updated at $(date '+%Y-%m-%d %H:%M:%S')" >> "ip-json/$country.json"

#!/bin/bash
set -e

echo "📥 开始抓取多个 IP 来源..."

# 设置 ipinfo.io 的 Token
IPINFO_TOKEN="${IPINFO_TOKEN:-your_ipinfo_token}"

# 创建输出目录
mkdir -p ip-json
> all_ips.txt

# 来源列表
urls=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
)

# 正则表达式提取 IP
regex_ip='([0-9]{1,3}\.){3}[0-9]{1,3}'

for url in "${urls[@]}"; do
  echo "🔗 抓取：$url"
  content=$(curl -s "$url")
  matches=$(echo "$content" | grep -Eo "$regex_ip")
  echo "$matches" >> all_ips.txt
done

# 去重
sort -u all_ips.txt -o all_ips.txt

echo "🌍 开始根据国家分类 IP 地址..."

# 清空旧分类
rm -f ip-json/*.json

while read -r ip; do
  country=$(curl -s --max-time 5 "https://ipinfo.io/$ip?token=$IPINFO_TOKEN" | grep -oP '"country":\s*"\K[A-Z]+')
  [[ -z "$country" ]] && continue
  echo "{\"ip\": \"$ip\"}," >> "ip-json/$country.json"
done < all_ips.txt

# 清理 JSON 尾部逗号，封装为数组（Linux sed 语法）
for file in ip-json/*.json; do
  sed -i '$s/,$//' "$file"
  sed -i '1s/^/[/' "$file"
  sed -i -e '$a]' "$file"
  echo "✅ 写入 $(basename "$file")"
done

echo "🎉 所有 IP 已分类完毕！"

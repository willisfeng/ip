#!/bin/bash

echo "📥 开始抓取多个 IP 来源..."

# 创建工作目录
WORKDIR="./ip/ip-json"
mkdir -p "$WORKDIR"
> all_ips.txt  # 清空旧数据

# 多个 IP 源网站
URLS=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.vvhan.com/"
  "https://cf.090227.xyz"
  "https://stock.hostmonit.com/CloudFlareYes"
)

# 抓取 IP
for URL in "${URLS[@]}"; do
  echo "🔗 抓取：$URL"
  curl -s "$URL" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> all_ips.txt
done

# 去重
sort -u all_ips.txt -o all_ips.txt

echo "🌍 开始根据国家分类 IP 地址..."

# 检查 IPINFO_TOKEN
if [[ -z "$IPINFO_TOKEN" ]]; then
  echo "❌ 缺少 IPINFO_TOKEN 环境变量"
  exit 1
fi

# 清空旧 JSON
rm -f "$WORKDIR"/*.json

# 遍历 IP 并归类
while read -r ip; do
  country=$(curl -s --max-time 10 ipinfo.io/$ip?token=$IPINFO_TOKEN | grep '"country"' | sed -E 's/.*: *"([^"]+)".*/\1/')
  [[ -z "$country" ]] && country="ZZ"

  echo "🔍 IP: $ip => 国家: $country"
  echo "\"$ip\"," >> "$WORKDIR/${country}.json"
done < all_ips.txt

# 美化 JSON 文件
for file in "$WORKDIR"/*.json; do
  # 去除最后一个逗号
  sed -i '$s/,$//' "$file"
  # 添加中括号包裹
  sed -i '1s/^/[/' "$file"
  echo "]" >> "$file"
  echo "✅ 写入 $file"
done

echo "🎉 所有 IP 收集与分类完成"

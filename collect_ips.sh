#!/bin/bash

echo "📥 开始抓取多个 IP 来源..."

# IP 源网址列表
sources=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.090227.xyz"
  "https://cf.vvhan.com/"
  "https://stock.hostmonit.com/CloudFlareYes"
)

# 匹配 IPv4 的正则表达式
ip_regex='([0-9]{1,3}\.){3}[0-9]{1,3}'

# 暂存所有 IP 的文件
all_ips_file="all_ips.txt"
> "$all_ips_file"

# 遍历所有来源
for url in "${sources[@]}"; do
  echo "🔗 抓取：$url"
  content=$(curl -s "$url")
  if [[ -n "$content" ]]; then
    echo "$content" | grep -Eo "$ip_regex" >> "$all_ips_file"
  fi
done

# 去重
sort -u "$all_ips_file" -o "$all_ips_file"

echo "🌍 开始根据国家分类 IP 地址..."

# 检查 IPINFO_TOKEN 是否设置
if [[ -z "$IPINFO_TOKEN" ]]; then
  echo "❌ 缺少 IPINFO_TOKEN，请设置环境变量。"
  exit 1
fi

# 创建输出文件夹
mkdir -p ip-json

# 分类写入
while read -r ip; do
  country=$(curl -s "https://ipinfo.io/$ip?token=${IPINFO_TOKEN}" | jq -r '.country // "UNKNOWN"')
  echo "🔍 IP: $ip => 国家: $country"
  echo "$ip" >> "ip-json/${country}.json"
done < "$all_ips_file"

# 将每个国家的 IP 转为 JSON 数组格式
for file in ip-json/*.json; do
  jq -Rs 'split("\n") | map(select(length > 0))' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

echo "✅ 所有 IP 已根据国家分类保存至 ip-json 文件夹中。"

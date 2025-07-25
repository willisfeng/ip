#!/bin/bash

echo "📥 开始收集 IP 地址列表..."

# 创建输出目录
mkdir -p ip-json
> all_ips.txt

# 测试国家列表（可按需添加）
countries=("US" "JP" "HK" "SG" "DE" "CN" "FR" "GB" "IN")

# 自定义 Cloudflare IPv4 公开地址段（如需更全可扩展）
ips=(
  104.16.0.0
  104.17.0.0
  104.18.0.0
  104.19.0.0
  104.20.0.0
  104.21.0.0
)

# 遍历每个 IP 查询国家
for ip in "${ips[@]}"; do
  country=$(curl -s "https://ipinfo.io/${ip}/country?token=${IPINFO_TOKEN}")
  echo "$ip $country" >> all_ips.txt
done

# 按国家分组写入 json 文件
for country in "${countries[@]}"; do
  grep " $country" all_ips.txt | cut -d' ' -f1 | jq -R . | jq -s . > ip-json/${country}.json
  echo "✅ 写入 ${country}.json"
done

echo "🎉 IP 收集完成。"

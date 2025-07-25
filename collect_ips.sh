#!/bin/bash
echo "📥 开始收集 IP 地址列表..."

# 检查 Token
if [ -z "$IPINFO_TOKEN" ]; then
  echo "❌ 缺少 IPINFO_TOKEN 环境变量"
  exit 1
fi

# 创建目录
mkdir -p ip-json
> all_ips.txt

# 生成 IPv4 Cloudflare 地址池（简化版本）
curl -s https://www.cloudflare.com/ips-v4 > cf_ipv4.txt

# 定义国家列表
countries=(US JP HK SG DE CN FR GB IN)

# 初始化国家-IP 映射
declare -A country_ips
for country in "${countries[@]}"; do
  country_ips["$country"]=""
done

# 遍历每个 IP，获取其国家信息
while read -r ip; do
  ip_check=$(curl -s --connect-timeout 2 "https://ipinfo.io/$ip?token=$IPINFO_TOKEN")
  country=$(echo "$ip_check" | jq -r '.country // empty')
  if [[ " ${countries[*]} " == *" $country "* ]]; then
    country_ips["$country"]+="$ip"$'\n'
    echo "$ip" >> all_ips.txt
  fi
done < cf_ipv4.txt

# 写入每个国家 JSON 文件
for country in "${countries[@]}"; do
  ips="${country_ips[$country]}"
  if [ -n "$ips" ]; then
    echo "$ips" | jq -R -s -c 'split("\n")[:-1]' > "ip-json/$country.json"
    echo "✅ 写入 $country.json"
  fi
done

echo "🎉 IP 收集完成。"

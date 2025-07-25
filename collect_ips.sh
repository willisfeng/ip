#!/bin/bash
set -e

echo "📥 正在获取 Cloudflare IPv4 列表..."

mkdir -p ip-json
rm -f all_ips.txt

# 拉取 Cloudflare IPv4 网段
curl -s https://www.cloudflare.com/ips-v4 -o all_ips.txt

echo "🌍 扫描所有 IP 国家归属并生成国家分类 JSON..."

# 使用 map.ipip.net API 获取国家
while IFS= read -r ip_range; do
  # 随机取一个 IP 用于归属地判断
  random_ip=$(prips "$ip_range" | shuf -n 1 2>/dev/null || true)
  [ -z "$random_ip" ] && continue

  # 查询国家代码
  country=$(curl -s "https://whois.pconline.com.cn/ipJson.jsp?ip=$random_ip&json=true" | iconv -f gbk -t utf-8 | jq -r '.proCode' || echo "ZZ")

  # 简化为国家码（你可以替换为其他 IP API）
  if [[ "$country" == "null" || "$country" == "" ]]; then
    country="ZZ"
  fi

  # 保存到对应国家的 json 文件
  ip_list=$(prips "$ip_range" | shuf -n 5 2>/dev/null | jq -R . | jq -s .)
  echo "$ip_list" > "ip-json/${country}.json"
  echo "✅ $ip_range 属于国家 $country"
done < all_ips.txt

echo "✅ 所有国家优选 IP 已生成于 ip-json 目录"

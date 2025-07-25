#!/bin/bash

echo "🌐 正在获取 Cloudflare IPv4 列表..."
curl -s https://www.cloudflare.com/ips-v4 -o all_ips.txt

echo "🔍 扫描所有 IP 国家归属并生成国家分类 JSON..."

mkdir -p ip-json

while read -r ip; do
    country=$(curl -s "https://ipinfo.io/${ip}/country" || echo "null")

    if [[ "$country" == "null" || -z "$country" ]]; then
        echo "❌ 路由归属国家码: null [$ip]"
        continue
    fi

    echo "✅ 路由归属国家码: $country [$ip]"
    echo "\"$ip\"" >> "ip-json/${country}.json"
done < all_ips.txt

# 格式化为 JSON 数组
for f in ip-json/*.json; do
    jq -Rs 'split("\n") | map(select(. != ""))' "$f" > tmp.json && mv tmp.json "$f"
done

echo "✅ 所有国家优选 IP 已生成于 ip-json 目录"

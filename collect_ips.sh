#!/bin/bash

echo "🌐 正在获取 Cloudflare IPv4 列表..."
curl -s https://www.cloudflare.com/ips-v4 -o cf_ipv4.txt

echo "🔍 扫描所有 IP 国家归属并生成国家分类 JSON..."

mkdir -p ip-json
> all_ips.txt

while IFS= read -r ip; do
    country_code=$(curl -s "http://ip-api.com/json/${ip}?fields=countryCode" | jq -r '.countryCode')

    if [[ -z "$country_code" || "$country_code" == "null" || "$country_code" =~ ^[0-9]+$ ]]; then
        echo "⛔️ 跳过非法国家码: $country_code [$ip]"
        continue
    fi

    echo "$ip,$country_code" >> all_ips.txt
    echo "✅ 收录: $ip 属于 $country_code"
done < cf_ipv4.txt

for country_code in $(cut -d',' -f2 all_ips.txt | sort | uniq); do
    ips=$(grep ",${country_code}$" all_ips.txt | cut -d',' -f1)
    ip_json=$(echo "$ips" | jq -R -s -c 'split("\n") | map(select(length>0))')
    echo "$ip_json" > "ip-json/${country_code}.json"
    echo "📝 写入 ip-json/${country_code}.json"
done

echo "🎉 所有国家优选 IP 已生成于 ip-json 目录"

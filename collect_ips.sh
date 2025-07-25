#!/bin/bash

echo "📥 开始收集 IP 地址列表..."

# 需要的国家标签
COUNTRIES=("US" "JP" "HK" "SG" "DE" "CN" "FR" "GB" "IN")

mkdir -p ip-json

> all_ips.txt
curl -s https://raw.githubusercontent.com/XIU2/CloudflareSpeedTest/master/ip.txt -o cf_ipv4.txt

for ip in $(cat cf_ipv4.txt); do
    echo "$ip" >> all_ips.txt
done

for country in "${COUNTRIES[@]}"; do
    > "ip-json/${country}.json"
done

for ip in $(cat all_ips.txt); do
    info=$(curl -s https://ipinfo.io/$ip?token=$IPINFO_TOKEN)
    country=$(echo $info | jq -r .country)

    if [[ " ${COUNTRIES[@]} " =~ " ${country} " ]]; then
        echo "\"$ip\"," >> ip-json/${country}.json
        echo "✅ $ip => $country"
    else
        echo "⏭️ $ip skipped ($country)"
    fi
done

# 修正每个 JSON 文件格式
for file in ip-json/*.json; do
    sed -i '' -e '$ s/,$//' "$file" # macOS sed
    sed -i '' -e '1s/^/[/' "$file"
    echo "]" >> "$file"
done

echo "🎉 IP 收集完成。"

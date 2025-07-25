#!/bin/bash
echo "🌐 正在获取 Cloudflare IPv4 列表..."
IPV4_LIST=$(curl -s https://www.cloudflare.com/ips-v4)

echo "🔍 扫描所有 IP 国家归属并生成国家分类 JSON..."
mkdir -p ip-json
> all_ips.txt

for ip in $IPV4_LIST; do
  echo "$ip" >> all_ips.txt
  COUNTRY=$(curl -s "https://api.ip.sb/geoip/${ip}" | jq -r '.country_code' || echo "null")

  if [[ "$COUNTRY" == "null" || -z "$COUNTRY" ]]; then
    echo "⚠️ 跳过无法识别国家: null [$ip]"
    continue
  fi

  echo "✅ $ip 属于国家代码: $COUNTRY"
  FILE="ip-json/${COUNTRY}.json"
  if [[ -f "$FILE" ]]; then
    jq -c ". + [\"$ip\"]" "$FILE" > tmp.json && mv tmp.json "$FILE"
  else
    echo "[\"$ip\"]" > "$FILE"
  fi
done

echo "✅ 所有国家优选 IP 已生成于 ip-json 目录"

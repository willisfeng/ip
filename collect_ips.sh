#!/bin/bash
set -e
mkdir -p result ip-json

IP_LIST_URL="https://www.cloudflare.com/ips-v4"
ALL_IP_LIST="all_ips.txt"
GEO_API="http://ip-api.com/json"

curl -s "$IP_LIST_URL" -o "$ALL_IP_LIST"
echo "✅ 已获取 Cloudflare IP 列表"

while read -r iprange; do
  rand_ip=$(nmap -n -sL $iprange 2>/dev/null | grep "Nmap scan report" | awk '{print $NF}' | shuf | head -n 1)
  if [[ -z "$rand_ip" ]]; then continue; fi

  country=$(curl -s "$GEO_API/$rand_ip" | jq -r '.countryCode')
  latency=$(ping -c 1 -W 1 $rand_ip | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
  if [[ -z "$latency" ]]; then continue; fi

  echo "$rand_ip,$latency" >> "result/$country.csv"
  echo "[$country] $rand_ip -> ${latency}ms"
done < "$ALL_IP_LIST"

python3 <<EOF
import csv, json, os
for file in os.listdir("result"):
    if file.endswith(".csv"):
        code = file.replace(".csv", "")
        with open(f"result/{file}") as f:
            reader = csv.reader(f)
            sorted_ips = sorted(reader, key=lambda x: float(x[1]))[:20]
            ip_list = [ip[0] for ip in sorted_ips]
            with open(f"ip-json/{code}.json", "w") as out:
                json.dump(ip_list, out, indent=2)
EOF

echo "✅ 所有国家优选 IP 已生成于 ip-json 目录"
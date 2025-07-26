#!/bin/bash

echo "📥 开始抓取多个 IP 来源..."

# 全部数据源
sources=(
  "https://api.uouin.com/cloudflare.html"
  "https://ip.164746.xyz"
  "https://cf.vvhan.com/"
  "https://cf.090227.xyz"
  "https://stock.hostmonit.com/CloudFlareYes"
)

ip_file="all_ips.txt"
> "$ip_file"

for url in "${sources[@]}"; do
  echo "🔗 抓取：$url"
  curl -s "$url" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' >> "$ip_file"
done

# 去重
sort -u "$ip_file" -o "$ip_file"

echo "🌍 开始根据国家分类 IP 地址..."

mkdir -p ip-json
> fallback.txt

declare -A country_ips
counter=0

while IFS= read -r ip; do
  # 限速，避免封锁
  sleep 0.2
  country=$(curl -s ipinfo.io/$ip?token=$IPINFO_TOKEN | grep '"country"' | awk -F '"' '{print $4}')
  if [[ -z "$country" ]]; then
    echo "⚠️ 无法识别国家：$ip"
    continue
  fi
  echo "🔍 IP: $ip => 国家: $country"

  # 保留前100个IP用于测速
  if [[ $counter -lt 100 ]]; then
    latency=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    latency=${latency:-9999}
    country_ips["$country"]+="$latency $ip"$'\n'
    ((counter++))
  fi
done < "$ip_file"

# fallback：添加 Cloudflare 香港默认 IP
echo "104.16.199.229" >> fallback.txt
echo "104.16.199.231" >> fallback.txt

for c in "${!country_ips[@]}"; do
  json_file="ip-json/${c}.json"
  echo "✅ 写入 $json_file"
  echo "[" > "$json_file"
  echo "${country_ips[$c]}" | sort -n | awk '{print "\""$2"\","}' | sed '$ s/,$//' >> "$json_file"
  echo "]" >> "$json_file"
done

echo "🎉 所有 IP 收集与分类完成"

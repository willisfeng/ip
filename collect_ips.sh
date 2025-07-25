#!/bin/bash
set -e

echo "📥 开始仅收集美国（US）IP 地址..."

# 确保已通过环境变量注入 Token
if [[ -z "${IPINFO_TOKEN}" ]]; then
  echo "❌ 请先设置环境变量 IPINFO_TOKEN"
  exit 1
fi

# 准备目录与临时文件
mkdir -p ip-json
> all_ips.txt
> ip-json/US.json

# 拉取 Cloudflare IPv4 列表
curl -s https://raw.githubusercontent.com/XIU2/CloudflareSpeedTest/master/ip.txt -o cf_ipv4.txt
cat cf_ipv4.txt >> all_ips.txt

# 按 IP 逐条检测
while read -r ip; do
  country=$(curl -s "https://ipinfo.io/${ip}?token=${IPINFO_TOKEN}" | jq -r .country)

  if [[ "$country" == "US" ]]; then
    echo "\"$ip\"," >> ip-json/US.json
    echo "✅ $ip 属于 US"
  else
    echo "⏭️ 跳过 $ip (country: $country)"
  fi
done < all_ips.txt

# 修正 JSON 格式（去除最后多余逗号并包裹数组）
if [[ -s ip-json/US.json ]]; then
  sed -i '' -e '$ s/,$//' ip-json/US.json    # macOS 语法，如 Linux 请去掉 ''
  sed -i '' -e '1s/^/[/' ip-json/US.json
  echo "]" >> ip-json/US.json
fi

echo "🎉 US IP 收集完成，结果保存在 ip-json/US.json"

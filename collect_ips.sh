#!/bin/bash

set -e

echo "📥 开始收集 IP 地址列表..."

# 确保输出目录存在
mkdir -p ip-json

# 设置 token
TOKEN="${IPINFO_TOKEN}"

# Cloudflare IPv4 节点来源
CF_SOURCE="https://www.cloudflare.com/ips-v4"
TMP_FILE="all_ips.txt"

# 下载全部 IPv4 IP
curl -s "$CF_SOURCE" -o "$TMP_FILE"

# 清理旧数据
rm -f ip-json/*.json

# 声明国家代码列表（可按需扩展）
COUNTRIES=(US JP HK SG DE CN FR GB IN)

# 遍历 IP，查国家
for COUNTRY in "${COUNTRIES[@]}"; do
  echo "🌍 正在处理 $COUNTRY ..."
  > "ip-json/${COUNTRY}.json"  # 清空原有文件

  while IFS= read -r ip; do
    info=$(curl -s --max-time 2 "https://ipinfo.io/$ip?token=${TOKEN}")
    country=$(echo "$info" | jq -r .country)

    if [[ "$country" == "$COUNTRY" ]]; then
      echo "\"$ip\"" >> "ip-json/${COUNTRY}.json"
    fi
  done < "$TMP_FILE"

  # JSON 格式化
  jq -s . "ip-json/${COUNTRY}.json" > tmp.json && mv tmp.json "ip-json/${COUNTRY}.json"
  echo "✅ 写入 ${COUNTRY}.json"
done

echo "🎉 IP 收集完成。"

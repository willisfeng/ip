#!/bin/bash

echo "📥 开始收集 IP 地址列表..."
mkdir -p ip-json

COUNTRIES=(US JP HK SG DE CN FR GB IN)

for COUNTRY in "${COUNTRIES[@]}"; do
    echo "🌐 正在抓取 $COUNTRY..."
    curl -s https://raw.githubusercontent.com/ethgan/yxip/main/${COUNTRY}.json -o ip-json/${COUNTRY}.json
    if [[ -s ip-json/${COUNTRY}.json ]]; then
        echo "✅ 写入 ${COUNTRY}.json"
    else
        echo "⚠️ 获取 ${COUNTRY}.json 失败"
        rm -f ip-json/${COUNTRY}.json
    fi
done

echo "🎉 IP 收集完成。"

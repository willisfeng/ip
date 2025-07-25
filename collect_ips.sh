#!/bin/bash

echo "📥 开始仅收集美国（US）IP 地址..."

# 创建存储目录
mkdir -p ip-json

# 初始化目标文件
> all_ips.txt
> ip-json/US.json

# 下载 Cloudflare IP 列表（推荐源）
curl -s https://raw.githubusercontent.com/XIU2/CloudflareSpeedTest/master/ip.txt -o cf_ipv4.txt

# 合并进 all_ips.txt
cat cf_ipv4.txt >> all_ips.txt

# 依次检查每个 IP
for ip in $(cat all_ips.txt); do
    info=$(curl -s https://ipinfo.io/$ip?token=你的_IPINFO_TOKEN)
    country=$(echo $info | jq -r .country)

    if [[ "$country" == "US" ]]; then
        echo "\"$ip\"," >> ip-json/US.json
        echo "✅ $ip 属于 US"
    else
        echo "❌ $ip 不是 US（是 $country）"
    fi
done

# 修正 JSON 文件格式
sed -i '' -e '$ s/,$//' ip-json/US.json  # macOS 用法，如在 Linux 可改为 sed -i '$ s/,$//' ...
sed -i '' -e '1s/^/[/' ip-json/US.json
echo "]" >> ip-json/US.json

echo "🎉 US IP 收集完成，保存在 ip-json/US.json 中"

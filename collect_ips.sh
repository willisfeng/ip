#!/bin/bash
set -e

echo "📥 正在获取 Cloudflare IPv4 列表..."
mkdir -p ip-json
rm -f all_ips.txt

curl -s https://www.cloudflare.com/ips-v4 -o all_ips.txt

echo "🌍 扫描所有 IP 国家归属并生成国家分类 JSON..."

while IFS= read -r ip_range; do
  # 随机取一个 IP 用于归属地判断
  random_ip=$(python3 -c "
import ipaddress, random;
net = ipaddress.IPv4Network('$ip_range', strict=False);
print(random.choice(list(net.hosts())))
" 2>/dev/null)

  if [[ -z "$random_ip" ]]; then
    continue
  fi

  country=$(curl -s "https://whois.pconline.com.cn/ipJson.jsp?ip=$random_ip&json=true" | iconv -f gbk -t utf-8 | jq -r '.proCode')
  [[ "$country" == "null" || "$country" == "" ]] && country="ZZ"

  # 创建一个包含当前网段前5个IP的json数组
  ip_list=$(python3 -c "
import ipaddress, json;
net = ipaddress.IPv4Network('$ip_range', strict=False);
ips = list(net.hosts())[:5];
print(json.dumps([str(ip) for ip in ips]))
")

  echo "$ip_list" > "ip-json/${country}.json"
  echo "✅ 已写入 ip-json/${country}.json"
done < all_ips.txt

echo "🎉 所有国家优选 IP 已生成于 ip-json 目录"

name: Update IP JSON Files

on:
  workflow_dispatch:
  schedule:
    - cron: '0 */12 * * *'  # 每12小时执行一次，可按需调整

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: 🌀 克隆仓库
        run: git clone https://github.com/Unc1e1u0-2030/ip.git ip

      - name: 🔧 设置 IPINFO_TOKEN 环境变量
        run: echo "IPINFO_TOKEN=${{ secrets.IPINFO_TOKEN }}" >> $GITHUB_ENV

      - name: ⚙️ 赋予脚本可执行权限
        run: chmod +x ./ip/collect_ips.sh

      - name: 📥 执行 IP 分类收集脚本
        run: ./ip/collect_ips.sh

      - name: 🛠️ 设置 Git 用户信息
        run: |
          cd ip
          git config --global user.name "github-actions[bot]"
          git config --global user.email "github-actions[bot]@users.noreply.github.com"

      - name: ✅ 提交变更到 GitHub
        run: |
          cd ip
          git add ip-json/*.json 2>/dev/null || echo "⚠️ 没有要提交的文件"
          git commit -m "✅ 自动更新 IP JSON 文件 - $(date '+%Y-%m-%d %H:%M:%S')" || echo "✅ 没有需要提交的更改"
          git push https://Unc1e1u0-2030:${{ secrets.GH_TOKEN }}@github.com/Unc1e1u0-2030/ip.git HEAD:main

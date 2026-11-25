#!/bin/bash
# 用法: TOKEN=你的github_token ./部署脚本.sh
set -e
cd "$(dirname "$0")"
if [ -z "$TOKEN" ]; then echo "请先设置 TOKEN 环境变量"; exit 1; fi
REPO="cwx-invest-site"

echo "=== 1. 创建 GitHub 仓库（已存在会跳过）==="
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO\",\"description\":\"CWX投资有限公司官网\",\"private\":false}" \
  | grep -E '"full_name"|"message"' | head -2 || true

echo "=== 2. 初始化并提交 ==="
git init -q
git add index.html CNAME .nojekyll README.md 部署说明.md
git -c user.name=xhchy -c user.email=358162235+xhchy@users.noreply.github.com commit -q -m "Deploy CWX invest site" || true

echo "=== 3. 推送 ==="
git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${TOKEN}@github.com/xhchy/${REPO}.git"
git branch -M main
git push -q -u origin main

echo "=== 4. 开启 GitHub Pages ==="
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/xhchy/$REPO/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' | grep -E '"html_url"|"message"' | head -2

echo "完成。网站地址: https://xhchy.github.io/$REPO/"
echo "绑定域名前，把 CNAME 文件里的 cwx-invest.example.com 改成你的真实域名并重新提交。"

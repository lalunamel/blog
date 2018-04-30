#! /usr/bin/env sh
# 1
# Builds junk

echo '### Building hexo site ###'
echo "#### node_modules/hexo/bin"
ls node_modules/hexo/bin
echo "#### node_modules/.bin"
ls node_modules/.bin
node_modules/hexo/bin/hexo generate --config _config-prod.yml --debug

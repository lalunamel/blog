#! /usr/bin/env sh
# 1
# Builds junk

echo '### Building hexo site ###'
node_modules/.bin/hexo generate --config _config-prod.yml --debug

#!/bin/bash
# Claude Code statusline: model, cwd, context window usage, and rate-limit usage stats.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$dir")

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

line="\033[2;36m${model}\033[0m \033[2m${dir_name}\033[0m"

if [ -n "$used_pct" ]; then
  line="${line} \033[2m|\033[0m \033[2;33mctx $(printf '%.0f' "$used_pct")%%\033[0m"
fi

rl=""
if [ -n "$five" ]; then
  rl="5h $(printf '%.0f' "$five")%%"
fi
if [ -n "$week" ]; then
  [ -n "$rl" ] && rl="${rl}  "
  rl="${rl}7d $(printf '%.0f' "$week")%%"
fi
if [ -n "$rl" ]; then
  line="${line} \033[2m|\033[0m \033[2;32m${rl}\033[0m"
fi

printf "${line}\n"

#!/usr/bin/env bash

printf 'Branch (aj/ prefix added automatically): '
IFS= read -r branch || exit 0
[[ -z "$branch" ]] && exit 0

case "$branch" in
  aj/*) ;;
  *) branch="aj/$branch" ;;
esac

if workmux add -- "$branch"; then
  exit 0
fi

printf '\nCould not create worktree. Press Enter to close.'
read -r
exit 1

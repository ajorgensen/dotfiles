function git-current-branch
  # display name of current active branch
  git symbolic-ref HEAD ^/dev/null | awk -F/ '{print $3;}'
end


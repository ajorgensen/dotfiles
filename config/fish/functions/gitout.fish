function gitout
  # count non-merge commits needing a push to origin
  if git cherry -v origin/(git-current-branch) >/dev/null ^/dev/null
    # vs outgoing branch if available
    git cherry -v origin/(git-current-branch) ^/dev/null
  else
    # otherwise compare to the master branch
    git cherry -v master ^/dev/null
  end
end

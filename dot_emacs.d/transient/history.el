((magit-blame
  ("-w"))
 (magit-diff
  ("--no-ext-diff" "--stat")
  ("--no-ext-diff"))
 (magit-dispatch nil)
 (magit-log
  ("-n256" "--graph" "--decorate")
  ("-n256" "--graph" "--color" "--decorate"))
 (magit-rebase
  ("--autostash")))

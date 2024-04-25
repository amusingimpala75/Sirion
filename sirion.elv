use github.com/href/elvish-gitstatus/gitstatus

var last-cmd-exit = 0

fn after-cmd-hook {|cmd|
  set last-cmd-exit = (if (eq $cmd[error] $nil) { put 0 } else { put 1 })
}

if (not (has-value $edit:after-command $after-cmd-hook~)) {
  set edit:after-command = [ $@edit:after-readline $after-cmd-hook~ ]
}

# clear the right prompt
set edit:rprompt = (constantly)

set edit:prompt = {
  styled (tilde-abbr $pwd) bright-blue

  var status = (gitstatus:query $pwd)

  if (bool $status[is-repository]) {
    styled ' ⎇ '$status[local-branch] bright-green
    if (bool $status[untracked]) {
      styled ' ?' red
    } elif (bool $status[uncomitted]) {
      styled ' +' yellow
    } elif (bool $status[unstaged]) {
      styled ' !' blue
    # renamed TODO
    # deleted TODO
    } elif (bool $status[stashes]) {
      styled ' $'
    # unmerged TODO
    } elif (bool $status[commits-ahead]) {
      styled ' ⇡'
    } elif (bool $status[commits-behind]) {
      styled ' ⇣'
    } elif (bool $status[conflicted]) {
      styled ' ⇕'
    }

    put ' '$status[commit]
    # time since last commit TODO
    if (!= $last-cmd-exit 0) {
      styled ' ✗' bright-red
    }
  }

  put "\n"
  put '→ '
}

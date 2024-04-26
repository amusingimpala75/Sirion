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
    if (!= 0 $status[untracked]) {
      styled ' ?' red
    } elif (!= 0 $status[unstaged]) {
      styled ' +' yellow
    } elif (!= 0 $status[staged]) {
      styled ' !' blue
    # renamed TODO
    # deleted TODO
    } elif (!= 0 $status[stashes]) {
      styled ' $'
    # unmerged TODO
    } elif (!= 0 $status[commits-ahead]) {
      styled ' ⇡'
    } elif (!= 0 $status[commits-behind]) {
      styled ' ⇣'
    } elif (!= 0 $status[conflicted]) {
      styled ' ⇕'
    }

    put ' '$status[commit][0..7]
    # time since last commit TODO
    if (!= 0 $last-cmd-exit) {
      styled ' ✗' bright-red
    }
  }

  put "\n"
  put '→ '
}

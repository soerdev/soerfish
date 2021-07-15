# name: soerfish
# This file is part of theme-soerfish

function _prompt_git -a gray normal orange red yellow
  set -l git_branch (_git_branch_name)
  test -z $git_branch; and return

  set dirty_remotes (_git_dirty_remotes $red $orange)
  if [ (_is_git_dirty) ]
    echo -n -s $gray '‹' $yellow $git_branch $red ' *' $dirty_remotes $gray '› '
  else
    echo -n -s $gray '‹' $yellow $git_branch $red $dirty_remotes $gray '› '
  end
end

function _prompt_pwd
  set_color -o cyan
  set -l cwd (basename (prompt_pwd))
  printf '%s' $cwd
end

function _prompt_status_arrows -a exit_code
  if test $exit_code -ne 0
    set arrow_colors 600 900 c00 f00
  else
    set arrow_colors 060 090 0c0 0f0
  end

  for arrow_color in $arrow_colors
    set_color $arrow_color
    printf '»'

  end
end

function _prompt_node -a color -d "Display currently activated Node"
  [ "$theme_display_node" != 'yes' ]; and return
  type -q node; or return
  type -q nvm; and begin; set -q NVM_BIN; or return; end # Lazy loading
  if [ "$NVM_BIN" != "$LAST_NVM_BIN" -o -z "$NODE_VERSION" ]
    set -gx NODE_VERSION (string trim -l -c=v (node -v 2>/dev/null))
    set -gx LAST_NVM_BIN $NVM_BIN
  end
  [ -n "$NODE_VERSION" ]; and echo -n -s $color \UE718" " $NODE_VERSION
end

function _prompt_versions -a yellow
  set -l prompt_node (_prompt_node $yellow)
  echo -n -e -s "$prompt_node" | string trim | tr -d '\n'
end

function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end

function _git_ahead_count -a remote -a branch_name
  echo (command git log $remote/$branch_name..HEAD 2> /dev/null | \
    grep '^commit' | wc -l | tr -d ' ')
end

function _git_dirty_remotes -a remote_color -a ahead_color
  set current_branch (command git rev-parse --abbrev-ref HEAD 2> /dev/null)
  set current_ref (command git rev-parse HEAD 2> /dev/null)

  for remote in (git remote | grep 'origin\|upstream')

    set -l git_ahead_count (_git_ahead_count $remote $current_branch)

    set remote_branch "refs/remotes/$remote/$current_branch"
    set remote_ref (git for-each-ref --format='%(objectname)' $remote_branch)
    if test "$remote_ref" != ''
      if test "$remote_ref" != $current_ref
        if [ $git_ahead_count != 0 ]
          echo -n "$remote_color!"
          echo -n "$ahead_color+$git_ahead_count$normal"
        end
      end
    end
  end
end

function _first_line_prompt -a gray normal orange
    [ "$theme_display_first_line" != 'yes' ]; and return

    printf $gray'['
    _prompt_pwd
    printf $gray'|'    
    _prompt_versions $orange
    printf $gray']'
    printf '\n'
end

function fish_prompt
    set -g exit_code $status

    set -l gray (set_color 777)
    set -l blue (set_color blue)
    set -l red (set_color red)
    set -l normal (set_color normal)
    set -l yellow (set_color yellow)
    set -l orange (set_color ff9900)
    set -l green (set_color green)


    _first_line_prompt $gray $normal $orange

    _prompt_git $gray $normal $orange $red $yellow
    _prompt_status_arrows $exit_code
    printf ' '

    set_color normal

end

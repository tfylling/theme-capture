###############################################################################
#
# Prompt theme name:
##   capture
#
# Description:
#   a powerline theme based on budpencer by Joseph Tannhuber
#
# Author:
#   Torbjørn Fylling <torbfylling@gmail.com>
#
# Sections:
#   -> TTY Detection
#   -> Functions
#     -> Toggle functions
#     -> Command duration segment
#     -> Git segment
#     -> PWD segment
#   -> Prompt
#
###############################################################################

###############################################################################
# => TTY Detection
###############################################################################

# Automatically disables right prompt when in a tty
# Except in Darwin due to OS X terminals identifying themselves as a tty
if not test (uname) = Darwin
  if tty | grep tty >/dev/null
    exit
  end
end

###############################################################################
# => Functions
###############################################################################

#####################
# => Toggle functions
#####################
function __capture_toggle_symbols -d 'Toggles style of symbols, press # in NORMAL or VISUAL mode'
  if [ $symbols_style = 'symbols' ]
    set symbols_style 'numbers'
  else
    set symbols_style 'symbols'
  end
  set pwd_hist_lock true
  commandline -f repaint
end

function __capture_toggle_pwd -d 'Toggles style of pwd segment, press space bar in NORMAL or VISUAL mode'
  for i in (seq (count $capture_pwdstyle))
    if [ $capture_pwdstyle[$i] = $pwd_style ]
      set pwd_style $capture_pwdstyle[(expr $i \% (count $capture_pwdstyle) + 1)]
      set pwd_hist_lock true
      commandline -f repaint
      break
      end
  end
end

#############################
# => Command duration segment
#############################
function __capture_cmd_duration -d 'Displays the elapsed time of last command'
  switch $pwd_style
    case short long
      set -l hundredths ''
      set -l seconds ''
      set -l minutes ''
      set -l hours ''
      set -l days ''
      set_color $capture_colors[2]
      echo -n ''
      if [ $last_status -ne 0 ]
        echo -n (set_color -b $capture_colors[2] $capture_colors[7])' '
      else
        echo -n (set_color -b $capture_colors[2] $capture_colors[12])' '
      end
      set hundredths (expr $CMD_DURATION / 10 \% 100)
      if [ $hundredths -lt 10 ]
        set hundredths '0'$hundredths
      end
      set -l cmd_duration (expr $CMD_DURATION / 1000)
      set seconds (expr $cmd_duration \% 68400 \% 3600 \% 60)
      if [ $cmd_duration -ge 60 ]
        set minutes (expr $cmd_duration \% 68400 \% 3600 / 60)'m'
        if [ $cmd_duration -ge 3600 ]
          set hours (expr $cmd_duration \% 68400 / 3600)'h'
          if [ $cmd_duration -ge 68400 ]
            set days (expr $cmd_duration / 68400)'d'
          end
        end
      end
      if [ $cmd_duration -lt 10 ]
        echo -n $seconds'.'$hundredths' '
      else
        echo -n $days$hours$minutes$seconds's '
      end
      set_color -b $capture_colors[2]
  end
end

################
# => Git segment
################
function __capture_is_git_ahead_or_behind -d 'Check if there are unpulled or unpushed commits'
  if set -l ahead_or_behind (command git rev-list --count --left-right 'HEAD...@{upstream}' 2> /dev/null)
    echo $ahead_or_behind | sed 's|\s\+|\n|g'
  else
    echo 0\n0
  end
end

function __capture_git_status -d 'Check git status'
  set -l git_status (command git status --porcelain 2> /dev/null | cut -c 1-2)
  set -l added (echo -sn $git_status\n | egrep -c "[ACDMT][ MT]|[ACMT]D")
  set -l deleted (echo -sn $git_status\n | egrep -c "[ ACMRT]D")
  set -l modified (echo -sn $git_status\n | egrep -c ".[MT]")
  set -l renamed (echo -sn $git_status\n | egrep -c "R.")
  set -l unmerged (echo -sn $git_status\n | egrep -c "AA|DD|U.|.U")
  set -l untracked (echo -sn $git_status\n | egrep -c "\?\?")
  echo -n $added\n$deleted\n$modified\n$renamed\n$unmerged\n$untracked
end

function __capture_is_git_stashed -d 'Check if there are stashed commits'
  command git log --format="%gd" -g $argv 'refs/stash' -- 2> /dev/null | wc -l | tr -d '[:space:]'
end

function __capture_prompt_git_symbols -d 'Displays the git symbols'
  set -l is_repo (command git rev-parse --is-inside-work-tree 2> /dev/null)
  if [ -z $is_repo ]
    return
  end

  set -l git_ahead_behind (__capture_is_git_ahead_or_behind)
  set -l git_status (__capture_git_status)
  set -l git_stashed (__capture_is_git_stashed)

  if [ (expr $git_ahead_behind[1] + $git_ahead_behind[2] + $git_status[1] + $git_status[2] + $git_status[3] + $git_status[4] + $git_status[5] + $git_status[6] + $git_stashed) -ne 0 ]
    set_color $capture_colors[3]
    echo -n ''
    set_color -b $capture_colors[3]
    switch $pwd_style
      case long short
        if [ $symbols_style = 'symbols' ]
          if [ $git_ahead_behind[1] -gt 0 ]
            set_color -o $capture_colors[5]
            echo -n ' ↑'
          end
          if [ $git_ahead_behind[2] -gt 0 ]
            set_color -o $capture_colors[5]
            echo -n ' ↓'
          end
          if [ $git_status[1] -gt 0 ]
            set_color -o $capture_colors[12]
            echo -n ' 落'
          end
          if [ $git_status[2] -gt 0 ]
            set_color -o $capture_colors[7]
            echo -n ' '
          end
          if [ $git_status[3] -gt 0 ]
            set_color -o $capture_colors[10]
            echo -n ' '
          end
          if [ $git_status[4] -gt 0 ]
            set_color -o $capture_colors[8]
            echo -n ' →'
          end
          if [ $git_status[5] -gt 0 ]
            set_color -o $capture_colors[9]
            echo -n ' ═'
          end
          if [ $git_status[6] -gt 0 ]
            set_color -o $capture_colors[4]
            echo -n ' ●'
          end
          if [ $git_stashed -gt 0 ]
            set_color -o $capture_colors[11]
            echo -n ' '
          end
        else
          if [ $git_ahead_behind[1] -gt 0 ]
            set_color $capture_colors[5]
            echo -n ' '$git_ahead_behind[1]
          end
          if [ $git_ahead_behind[2] -gt 0 ]
            set_color $capture_colors[5]
            echo -n ' '$git_ahead_behind[2]
          end
          if [ $git_status[1] -gt 0 ]
            set_color $capture_colors[12]
            echo -n ' '$git_status[1]
          end
          if [ $git_status[2] -gt 0 ]
            set_color $capture_colors[7]
            echo -n ' '$git_status[2]
          end
          if [ $git_status[3] -gt 0 ]
            set_color $capture_colors[10]
            echo -n ' '$git_status[3]
          end
          if [ $git_status[4] -gt 0 ]
            set_color $capture_colors[8]
            echo -n ' '$git_status[4]
          end
          if [ $git_status[5] -gt 0 ]
            set_color $capture_colors[9]
            echo -n ' '$git_status[5]
          end
          if [ $git_status[6] -gt 0 ]
            set_color $capture_colors[4]
            echo -n ' '$git_status[6]
          end
          if [ $git_stashed -gt 0 ]
            set_color $capture_colors[11]
            echo -n ' '$git_stashed
          end
        end
        set_color -b $capture_colors[3] normal
        echo -n ' '
    end
  end
end

function __capture_prompt_git_branch -d 'Return the current branch name'
  set -l branch (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
  if not test $branch > /dev/null
    set -l position (command git describe --contains --all HEAD 2> /dev/null)
    if not test $position > /dev/null
      set -l commit (command git rev-parse HEAD 2> /dev/null | sed 's|\(^.......\).*|\1|')
      if test $commit
        set_color -b $capture_colors[11]
        switch $pwd_style
          case short long
            echo -n ''(set_color $capture_colors[1])' ➦ '$commit' '(set_color $capture_colors[11])
          case none
            echo -n ''
        end
        set_color normal
        set_color $capture_colors[11]
      end
    else
      set_color -b $capture_colors[9]
      switch $pwd_style
        case short long
          echo -n ''(set_color $capture_colors[1])'  '$position' '(set_color $capture_colors[9])
        case none
          echo -n ''
      end
      set_color normal
      set_color $capture_colors[9]
    end
  else
    set_color -b $capture_colors[3]
    switch $pwd_style
      case short long
        echo -n ''(set_color $capture_colors[1])'  '$branch' '(set_color $capture_colors[3])
      case none
        echo -n ''
    end
    set_color normal
    set_color $capture_colors[3]
  end
end

###############################################################################
# => Prompt
###############################################################################

function fish_right_prompt -d 'Write out the right prompt of the capture theme'
  echo -n -s (__capture_cmd_duration) (__capture_prompt_git_symbols) (__capture_prompt_git_branch)
  set_color normal
end

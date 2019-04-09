###############################################################################
#
# Prompt theme name:
#   capture
#
# Description:
#   a powerline theme based on budpencer by Joseph Tannhuber
#
# Author:
#   Torbjørn Fylling <torbfylling@gmail.com>
#
###############################################################################

###############################################################################
# => Color definitions
###############################################################################

# Define colors
set -U capture_color_fg_dark 000000
set -U capture_color_fg_light fdf6e3
if [ $USER = 'root' ]
  set -U capture_color_bg_theme_primary bd4b43
else
  set -U capture_color_bg_theme_primary 2990b5
end
set -U capture_color_fg_theme_primary $capture_color_fg_light
set -U capture_color_bg_theme_secondary 14475a
set -U capture_color_fg_theme_secondary $capture_color_fg_light
set -U capture_color_bg_os $capture_color_fg_light
set -U capture_color_fg_os $capture_color_bg_theme_primary
set -U capture_color_fg_ok_text 859900
set -U capture_color_fg_error_text dc121f
set -U capture_color_bg_error_segment dc121f
set -U capture_color_fg_error_segment $capture_color_fg_dark
set -U capture_color_bg_git_commit 2aa198
set -U capture_color_fg_git_commit $capture_color_fg_dark
set -U capture_color_bg_git_position 6c71c4
set -U capture_color_fg_git_position $capture_color_fg_dark
set -U capture_color_bg_git_branch 445659
set -U capture_color_fg_git_branch $capture_color_fg_light
set -U capture_color_bg_virtual_env $capture_color_fg_light
set -U capture_color_fg_virtual_env $capture_color_bg_theme_primary
set -U capture_color_bg_key_bindings $capture_color_fg_light
set -U capture_color_fg_key_bindings $capture_color_bg_theme_primary
set -U capture_color_bg_duration $capture_color_bg_theme_primary
set -U capture_color_fg_duration $capture_color_fg_light
set -U capture_color_bg_return_code_ok $capture_color_fg_light
set -U capture_color_fg_return_code_ok $capture_color_fg_ok_text
set -U capture_color_bg_return_code_error ff0000
set -U capture_color_fg_return_code_error ffff00

#set -U capture_color_bg_next $capture_color_bg_theme_primary

set -U capture_night 000000 083743 445659 fdf6e3 2990b5 cb4b16 dc121f af005f 6c71c4 268bd2 2aa198 859900
#                    0      1      2      3      4      5      6      7      8      9      10     11
set -U capture_day 000000 333333 666666 ffffff ffff00 ff6600 ff0000 ff0033 3300ff 00aaff 00ffff 00ff00
if not set -q capture_colors
  # Values are: black dark_gray light_gray white yellow orange red magenta violet blue cyan green
  set -U capture_colors $capture_night
end

# Cursor color changes according to vi-mode
# Define values for: normal_mode insert_mode visual_mode
set -U capture_cursors "\033]12;#$capture_colors[10]\007" "\033]12;#$capture_colors[5]\007" "\033]12;#$capture_colors[8]\007" "\033]12;#$capture_colors[9]\007"

set -U signals "HUP" "INT" "QUIT" "ILL" "TRAP" "ABRT" "BUS" "FPE" "KILL" "USR1" "EGV" "USR2" "PIPE" "ALRM" "TERM" "STKFLT" "CHLD" "CONT" "STOP" "TSTP" "TTIN" "TTOU" "URG" "XCPU" "XFSZ" "VTALRM" "PROF" "WINCH" "IO" "PWR" "UNUSED"
set -U VIRTUAL_ENV_DISABLE_PROMPT 1

###############################################################################
# => Files
###############################################################################

# Config file
set -g capture_config "$HOME/.config/fish/capture_config.fish"

# Temporary files
set -g capture_tmpfile '/tmp/'(echo %self)'_capture_edit.fish'

###############################################################################
# => Functions
###############################################################################

##############
# => Ring bell
##############
if set -q capture_nobell
  function __capture_urgency -d 'Do nothing.'
  end
else
  function __capture_urgency -d 'Ring the bell in order to set the urgency hint flag.'
    echo -n \a
  end
end

#################
# => Window title
#################
function wt -d 'Set window title'
  set -g window_title $argv
  function fish_title
    echo -n $window_title
  end
end

################
# => Pre execute
################
function __capture_preexec -d 'Execute after hitting <Enter> before doing anything else'
  commandline -f execute
  return
  set -l cmd (commandline | sed 's|\s\+|\x1e|g')
  if [ $_ = 'fish' ]
    if [ -z $cmd[1] ]
      set -e cmd[1]
    end
    if [ -z $cmd[1] ]
      return
    end
    set -e capture_prompt_error[1]
    if not type -q $cmd[1]
      if [ -d $cmd[1] ]
        set capture_prompt_error (cd $cmd[1] 2>&1)
        and commandline ''
        commandline -f repaint
        return
      end
    end
    switch $cmd[1]
      case 'cd'
        if [ (count $cmd) -le 2 ]
          set capture_prompt_error (eval $cmd 2>&1)
          and commandline ''
          if [ (count $capture_prompt_error) -gt 1 ]
            set capture_prompt_error $capture_prompt_error[1]
          end
          commandline -f repaint
          return
        end
    end
  end
  commandline -f execute
end

#####################
# => Fish termination
#####################
function __capture_on_termination -s HUP -s INT -s QUIT -s TERM --on-process %self -d 'Execute when shell terminates'
  set -l item (contains -i %self $capture_sessions_active_pid 2> /dev/null)
  __capture_detach_session $item
end


##############
# => Bookmarks
##############
function mark -d 'Create bookmark for present working directory.'
  if not contains $PWD $bookmarks
    set -U bookmarks $PWD $bookmarks
    set pwd_hist_lock true
    commandline -f repaint
  end
end

function unmark -d 'Remove bookmark for present working directory.'
  if contains $PWD $bookmarks
    set -e bookmarks[(contains -i $PWD $bookmarks)]
    set pwd_hist_lock true
    commandline -f repaint
  end
end

function m -d 'List bookmarks, jump to directory in list with m <number>'
  set -l num_items (count $bookmarks)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Bookmark list is empty. '(set_color normal)'Enter '(set_color $fish_color_command[1])'mark '(set_color normal)'in INSERT mode or '(set_color $fish_color_command[1])'m '(set_color normal)'in NORMAL mode, if you want to add the current directory to your bookmark list.'
    return
  end
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    cd $bookmarks[(expr $num_items - $argv[1])]
  else
    for i in (seq $num_items)
      if [ $PWD = $bookmarks[$i] ]
        set_color $capture_colors[10]
      else
        if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
          set_color normal
        else
          set_color $capture_colors[4]
        end
      end
      echo '▶ '(expr $num_items - $i)\t$bookmarks[$i] | sed "s|$HOME|~|"
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $capture_cursors[1]
    set input_length (expr length (expr $num_items - 1))
    read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[10])" ⌘ Goto [0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[10])' -n $input_length -l dir_num
    switch $dir_num
      case (seq 0 (expr $num_items - 1))
        cd $bookmarks[(expr $num_items - $dir_num)]
    end
    for i in (seq (expr $num_items + 1))
      tput cuu1
    end
    tput ed
    tput cuu1
  end
end

#############
# => Sessions
#############
function __capture_delete_zombi_sessions -d 'Delete zombi sessions'
  for i in $capture_sessions_active_pid
    if not contains $i %fish
      set -l item (contains -i $i $capture_sessions_active_pid)
      set -e capture_sessions_active_pid[$item]
      set -e capture_sessions_active[$item]
    end
  end
end

function __capture_create_new_session -d 'Create a new session'
  set -U capture_session_cmd_hist_$argv[1] $$cmd_hist
  set -U capture_session_dir_hist_$argv[1] $$dir_hist
  set -U capture_sessions $argv[1] $capture_sessions
end

function __capture_erase_session -d 'Erase current session'
  if [ (count $argv) -eq 1 ]
    set_color $fish_color_error[1]
    echo 'Missing argument: name of session to erase'
    return
  end
  if contains $argv[2] $capture_sessions_active
    set_color $fish_color_error[1]
    echo "Session '$argv[2]' cannot be erased because it's currently active."
    return
  end
  if contains $argv[2] $capture_sessions
    set -e capture_session_cmd_hist_$argv[2]
    set -e capture_session_dir_hist_$argv[2]
    set -e capture_sessions[(contains -i $argv[2] $capture_sessions)]
  else
    set_color $fish_color_error[1]
    echo "Session '$argv[2]' not found. "(set_color normal)'Enter '(set_color $fish_color_command[1])'s '(set_color normal)'to show a list of all recorded sessions.'
  end
end

function __capture_detach_session -d 'Detach current session'
  set cmd_hist cmd_hist_nosession
  set dir_hist dir_hist_nosession
  if [ -z $$dir_hist ] 2> /dev/null
    set $dir_hist $PWD
  end
  set dir_hist_val (count $$dir_hist)
  set -e capture_sessions_active_pid[$argv] 2> /dev/null
  set -e capture_sessions_active[$argv] 2> /dev/null
  set capture_session_current ''
  cd $$dir_hist[1][$dir_hist_val]
  set no_prompt_hist 'T'
end

function __capture_attach_session -d 'Attach session'
  set argv (echo -sn $argv\n | sed 's|[^[:alnum:]]|_|g')
  if contains $argv[1] $capture_sessions_active
    wmctrl -a "✻ $argv[1]"
  else
    wt "✻ $argv[1]"
    __capture_detach_session $argv[-1]
    set capture_sessions_active $capture_sessions_active $argv[1]
    set capture_sessions_active_pid $capture_sessions_active_pid %self
    set capture_session_current $argv[1]
    if not contains $argv[1] $capture_sessions
      __capture_create_new_session $argv[1]
    end
    set cmd_hist capture_session_cmd_hist_$argv[1]
    set dir_hist capture_session_dir_hist_$argv[1]
    if [ -z $$dir_hist ] 2> /dev/null
      set $dir_hist $PWD
    end
    set dir_hist_val (count $$dir_hist)
    cd $$dir_hist[1][$dir_hist_val] 2> /dev/null
  end
  set no_prompt_hist 'T'
end

function s -d 'Create, delete or attach session'
  __capture_delete_zombi_sessions
  if [ (count $argv) -eq 0 ]
    set -l active_indicator
    set -l num_items (count $capture_sessions)
    if [ $num_items -eq 0 ]
      set_color $fish_color_error[1]
      echo -n 'Session list is empty. '
      set_color normal
      echo -n 'Enter '
      set_color $fish_color_command[1]
      echo -n 's '
      set_color $fish_color_param[1]
      echo -n 'session-name'
      set_color normal
      echo ' to record the current session.'
      return
    end
    for i in (seq $num_items)
      if [ $capture_sessions[$i] = $capture_session_current ]
        set_color $capture_colors[8]
      else
        if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
          set_color normal
        else
          set_color $capture_colors[4]
        end
      end
      if contains $capture_sessions[$i] $capture_sessions_active
        set active_indicator '✻ '
      else
        set active_indicator ' '
      end
      echo '▶ '(expr $num_items - $i)\t$active_indicator$capture_sessions[$i]
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $capture_cursors[3]
    set input_length (expr length (expr $num_items - 1))
    read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[8])" ✻ Attach [e|0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[8])' -n $input_length -l session_num
    set pcount (expr $pcount - 1)
    switch $session_num
      case (seq 0 (expr $num_items - 1))
        set argv[1] $capture_sessions[(expr $num_items - $session_num)]
        for i in (seq (expr $num_items + 1))
          tput cuu1
        end
        tput ed
        tput cuu1
      case 'e'
        read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[8])" ✻ Erase [0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[8])' -n $input_length -l session_num
        if [ (expr $num_items - $session_num) -gt 0 ]
          __capture_erase_session -e $capture_sessions[(expr $num_items - $session_num)]
        end
        for i in (seq (expr $num_items + 3))
          tput cuu1
        end
        tput ed
        return
      case '*'
        for i in (seq (expr $num_items + 1))
          tput cuu1
        end
        tput ed
        tput cuu1
        return
    end
  end
  set -l item (contains -i %self $capture_sessions_active_pid 2> /dev/null)
  switch $argv[1]
    case '-e'
      __capture_erase_session $argv
    case '-d'
      wt 'fish'
      __capture_detach_session $item
      tput cuu1
      tput ed
      set pcount (expr $pcount - 1)
    case '-*'
      set_color $fish_color_error[1]
      echo "Invalid argument: $argv[1]"
    case '*'
      __capture_attach_session $argv $item
  end
end

#####################################
# => Commandline editing with $EDITOR
#####################################
function __capture_edit_commandline -d 'Open current commandline with your editor'
  commandline > $capture_tmpfile
  eval $EDITOR $capture_tmpfile
  set -l IFS ''
  if [ -s $capture_tmpfile ]
    commandline (sed 's|^\s*||' $capture_tmpfile)
  else
    commandline ''
  end
  rm $capture_tmpfile
end

###############################
# => Append left prompt segment
###############################
function __capture_append_left_prompt_segment -d 'Append a segment to the left prompt'
  if not [ $argv ]
    return
  end
  if set -q capture_color_bg_last
    if [ $capture_color_bg_next = $capture_color_bg_last ]
      echo ''
    else
      set_color $capture_color_bg_next
      set_color -r
      echo ''
    end
    set_color normal
  end
  set_color -b $capture_color_bg_next
  echo $argv
  set -g capture_color_bg_last $capture_color_bg_next
  set -g capture_first_segment 0
end

################################
# => Append right prompt segment
################################
function __capture_append_right_prompt_segment -d 'Append a segment to the right prompt'
  if not [ $argv ]
    return
  end
  set_color $capture_color_bg_next
  echo ''
  set_color -b $capture_color_bg_next
  echo $argv
end

#########################
# => Key Bindings segment
#########################
function __capture_prompt_key_bindings -d 'Print key bindings mode'
  [ "$theme_display_vi" != 'no' ]
  or return
  set -g capture_color_bg_next $capture_color_bg_virtual_env
  set_color $capture_color_fg_virtual_env
  [ "$fish_key_bindings" = 'fish_vi_key_bindings' \
      -o "$fish_key_bindings" = 'hybrid_bindings' \
      -o "$fish_key_bindings" = 'fish_hybrid_key_bindings' \
      -o "$theme_display_vi" = 'yes' ]
  or return
  switch $fish_bind_mode
    case default
      echo -n ' N '
    case insert
      echo -n ' I '
    case replace_one replace-one
      echo -n ' R '
    case visual
      echo -n ' V '
  end
end


########################
# => Virtual Env segment
########################
function __capture_prompt_virtual_env -d 'Return the current virtual env name'
  if set -q VIRTUAL_ENV
    set -g capture_color_bg_next $capture_color_bg_virtual_env
    set_color $capture_color_fg_virtual_env
    echo -n ' ('(basename "$VIRTUAL_ENV")') '
  end
end

################
# => PWD segment
################
function __capture_prompt_pwd -d 'Displays the present working directory'
  set -g capture_color_bg_next $capture_color_bg_theme_primary
  set_color $capture_color_fg_theme_primary
  set -l user_host ' '
  if set -q SSH_CLIENT
    set user_host " $USER@"(hostname -s)':'
  end
  if [ (count $capture_prompt_error) != 1 ]
    set -l home_path ~
    set short_path (pwd | sed "s|^$home_path|~|")
    set path_elements (echo $short_path | string split "/")
    if [ (count $path_elements) -gt 3 ]
      set short_path '…/'$path_elements[-2]'/'$path_elements[-1]
    end
    if [ $short_path = '~' ]
      set pwd_icon ''
    else
      if [ $path_elements[2] = "etc" ]
        set pwd_icon ''
      else if [ $path_elements[1] = "~" ]
        set pwd_icon ''
      else
        set pwd_icon ''
      end
    end
    echo -n ' '$pwd_icon' '$short_path' '
  else
    echo -n " $capture_prompt_error "
    set -e capture_prompt_error[1]
  end
end

#############################
# => Command duration segment
#############################
function __capture_cmd_duration -d 'Displays the elapsed time of last command'
  set -g capture_color_bg_next $capture_color_bg_duration
  set -l hundredths ''
  set -l seconds ''
  set -l minutes ''
  set -l hours ''
  set -l days ''
  set -l hundredths (expr $CMD_DURATION / 10 \% 100)
  if [ $hundredths -lt 10 ]
    set -l hundredths '0'$hundredths
  end
  set -l cmd_duration (expr $CMD_DURATION / 1000)
  set -l seconds (expr $cmd_duration \% 68400 \% 3600 \% 60)
  if [ $cmd_duration -ge 60 ]
    set -l minutes (expr $cmd_duration \% 68400 \% 3600 / 60)'m'
    if [ $cmd_duration -ge 3600 ]
      set hours (expr $cmd_duration \% 68400 / 3600)'h'
      if [ $cmd_duration -ge 68400 ]
        set -l days (expr $cmd_duration / 68400)'d'
      end
    end
  end
  set_color $capture_color_fg_duration
  echo -n '  '
  if [ $cmd_duration -lt 10 ]
    echo -n $seconds'.'$hundredths's'
  else
    echo -n $days$hours$minutes$seconds's'
  end
end

########################
# => Return code segment
########################
function __capture_return_code -d 'Displays the return code of the last command'
  if [ $last_status -eq 0 ]
    set -g capture_color_bg_next $capture_color_bg_return_code_ok
    set_color $capture_color_fg_return_code_ok
    echo -n '  '
  else
    set -g capture_color_bg_next $capture_color_bg_return_code_error
    set_color $capture_color_fg_return_code_error
    echo -n ' '
    if [ $last_status -gt 128 ]
      set -l last_status (expr $last_status - 128)
      echo -n 'SIG'$signals[$last_status]'('$last_status')'
    else
      echo -n $last_status
    end
    echo -n '  '
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
    if [ $git_ahead_behind[1] -gt 0 ]
      set_color -o $capture_colors[5]
      echo -n ' ↑ '$git_ahead_behind[1]' '
    end
    if [ $git_ahead_behind[2] -gt 0 ]
      set_color -o $capture_colors[5]
      echo -n ' ↓ '$git_ahead_behind[2]' '
    end
    if [ $git_status[1] -gt 0 ]
      set_color -o $capture_colors[12]
      echo -n ' 落'$git_status[1]' '
    end
    if [ $git_status[2] -gt 0 ]
      set_color -o $capture_colors[7]
      echo -n '  '$git_status[2]' '
    end
    if [ $git_status[3] -gt 0 ]
      set_color -o $capture_colors[10]
      echo -n '  '$git_status[3]' '
    end
    if [ $git_status[4] -gt 0 ]
      set_color -o $capture_colors[8]
      echo -n ' → '$git_status[4]' '
    end
    if [ $git_status[5] -gt 0 ]
      set_color -o $capture_colors[9]
      echo -n ' ═ '$git_status[5]' '
    end
    if [ $git_status[6] -gt 0 ]
      set_color -o $capture_colors[4]
      echo -n ' ● '$git_status[6]' '
    end
    if [ $git_stashed -gt 0 ]
      set_color -o $capture_colors[11]
      echo -n '  '$git_stashed' '
    end
  end
  echo ' '
end

function __capture_prompt_git_branch -d 'Return the current branch name'
  set -l branch (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
  if not test $branch > /dev/null
    set -l position (command git describe --contains --all HEAD 2> /dev/null)
    if not test $position > /dev/null
      set -l commit (command git rev-parse HEAD 2> /dev/null | sed 's|\(^.......\).*|\1|')
      if test $commit
        set -g capture_color_bg_next $capture_color_bg_git_commit
        set_color $capture_color_fg_git_commit
        echo -n '  ➦ '$commit
      end
    else
      set -g capture_color_bg_next $capture_color_bg_git_position
      set_color $capture_color_fg_git_position
      set -l position (echo -n $position | sed -e 's|tags/| |')
      echo -n '  '$position
    end
  else
    set -g capture_color_bg_next $capture_color_bg_git_branch
    set_color $capture_color_fg_git_branch
    echo -n '   '$branch
  end
  __capture_prompt_git_symbols
end

###############
# => OS segment
###############
function __capture_prompt_os_icon -d 'Displays icon for current OS'
  set -g capture_color_bg_next $capture_color_bg_os
  # TODO: fix lookup
  set os_icon ''
  echo -n (set_color $capture_color_fg_os)' '$os_icon' '
end

####################
# => Symbols segment
####################
function __capture_prompt_symbols -d 'Display symbols'
  set -g capture_color_bg_next $capture_color_bg_theme_secondary
  set -l jobs (jobs | wc -l | tr -d '[:space:]')
  set -l symbols ''
  if [ -e ~/.taskrc ]
    set todo (task due.before:sunday 2> /dev/null | tail -1 | cut -f1 -d' ')
    set overdue (task due.before:today 2> /dev/null | tail -1 | cut -f1 -d' ')
  end
  if [ -e ~/.reminders ]
    set appointments (rem -a | cut -f1 -d' ')
  end
  if [ (count $todo) -eq 0 ]
    set todo 0
  end
  if [ (count $overdue) -eq 0 ]
    set overdue 0
  end
  if [ (count $appointments) -eq 0 ]
    set appointments 0
  end
  if [ $capture_session_current != '' ]
    set symbols $symbols(set_color -o $capture_colors[8])' ✻'
  end
  if contains $PWD $bookmarks
    set symbols $symbols(set_color -o $capture_colors[10])' ⌘'
  end
  if set -q -x VIM
    set symbols $symbols(set_color -o $capture_colors[9])' '
  end
  if set -q -x RANGER_LEVEL
    set symbols $symbols(set_color -o $capture_colors[9])' R'
  end
  if [ $jobs -gt 0 ]
    set symbols $symbols(set_color -o $capture_colors[11])' ⚙'
  end
  if [ ! -w . ]
    set symbols $symbols(set_color -o $capture_colors[6])' '
  end
  if [ $todo -gt 0 ]
    set symbols $symbols(set_color -o $capture_colors[4])
  end
  if [ $overdue -gt 0 ]
    set symbols $symbols(set_color -o $capture_colors[8])
  end
  if [ (expr $todo + $overdue) -gt 0 ]
    set symbols $symbols' ⚔'
  end
  if [ $appointments -gt 0 ]
    set symbols $symbols(set_color -o $capture_colors[5])' ⚑'
  end
  if [ $USER = 'root' ]
    set symbols $symbols(set_color -o $capture_colors[6])' ⚡'
  end
#  if [ $last_status -eq 0 ]
#    set symbols $symbols(set_color -o $capture_colors[12])' ✔'
#  else
#    set symbols $symbols(set_color -o $capture_colors[7])' ✘'
#  end
  if [ $symbols != '' ]
    set symbols $symbols(set_color $capture_colors[2])' '(set_color normal)(set_color $capture_colors[2])
    echo -n $symbols
  end
end

###############################################################################
# => Prompt initialization
###############################################################################

# Initialize some global variables
set -g capture_prompt_error
set -g capture_current_bindmode_color
set -U capture_sessions_active $capture_sessions_active
set -U capture_sessions_active_pid $capture_sessions_active_pid
set -g capture_session_current ''
set -g cmd_hist_nosession
set -g cmd_hist cmd_hist_nosession
set -g CMD_DURATION 0
set -g dir_hist_nosession
set -g dir_hist dir_hist_nosession
set -g pwd_hist_lock true
set -g pcount 1
set -g prompt_hist
set -g no_prompt_hist 'F'
set -g symbols_style 'symbols'

# Load user defined key bindings
if functions --query fish_user_key_bindings
  fish_user_key_bindings
end

# Set favorite editor
if not set -q EDITOR
  set -g EDITOR vim
end

# Source config file
if [ -e $capture_config ]
  source $capture_config
end

###############################################################################
# => Left prompt
###############################################################################

function fish_prompt -d 'Write out the left prompt of the capture theme'
  set -g last_status $status
  set -e capture_color_bg_last
  set -g capture_first_segment 1
  echo -n -s \
             (__capture_append_left_prompt_segment (__capture_prompt_os_icon)) \
             (__capture_append_left_prompt_segment (__capture_prompt_key_bindings)) \
             (__capture_append_left_prompt_segment (__capture_prompt_virtual_env)) \
             (__capture_append_left_prompt_segment (__capture_prompt_pwd)) \
             (__capture_append_left_prompt_segment (__capture_prompt_symbols)) \
             (set_color normal)(set_color $capture_color_bg_last)' '(set_color normal)
  if [ $USER = 'root' ]
    echo -e -n " \b"
  end
end

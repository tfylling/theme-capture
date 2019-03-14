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
# Sections:
#   -> Color definitions
#   -> Files
#   -> Functions
#     -> Ring bell
#     -> Window title
#     -> Help
#     -> Environment
#     -> Pre execute
#     -> Directory history
#     -> Command history
#     -> Bookmarks
#     -> Sessions
#     -> Commandline editing with $EDITOR
#     -> Git segment
#     -> Bind-mode segment
#     -> Symbols segment
#   -> Prompt initialization
#   -> Left prompt
#
###############################################################################

###############################################################################
# => Color definitions
###############################################################################

# Define colors
set -U capture_color_fg_dark 000000
set -U capture_color_fg_light fdf6e3
set -U capture_color_bg_theme_primary 2990b5
set -U capture_color_fg_theme_primary $capture_color_fg_dark
set -U capture_color_bg_theme_secondary 083743
set -U capture_color_fg_theme_secondary $capture_color_fg_light
set -U capture_color_fg_ok_text 859900
set -U capture_color_fg_error_text dc121f
set -U capture_color_bg_error_segment dc121f
set -U capture_color_fg_error_segment $capture_color_fg_dark
set -U capture_color_bg_git_main 445659
set -U capture_color_fg_git_main $capture_color_fg_dark
set -U capture_color_bg_git_tag 6c71c4
set -U capture_color_fg_git_tag $capture_color_fg_dark
set -U capture_color_bg_virtual_env 268bd2
set -U capture_color_fg_virtual_env $capture_color_fg_dark

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

#########
# => Help
#########
function capture_help -d 'Show helpfile'
  set -l readme_file "$OMF_PATH/themes/capture/README.md"
  if set -q PAGER
    if [ -e $readme_file ]
      eval $PAGER $readme_file
      else
        set_color $fish_color_error[1]
        echo "$readme_file wasn't found."
      end
  else
    open $readme_file
  end
end

################
# => Pre execute
################
function __capture_preexec -d 'Execute after hitting <Enter> before doing anything else'
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
      case 'c'
        if begin
            [ (count $cmd) -gt 1 ]
            and [ $cmd[2] -gt 0 ]
            and [ $cmd[2] -lt $pcount ]
          end
          commandline $prompt_hist[$cmd[2]]
          echo $prompt_hist[$cmd[2]] | xsel
          commandline -f repaint
          return
        end
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

######################
# => Directory history
######################
function __capture_create_dir_hist -v PWD -d 'Create directory history without duplicates'
  if [ "$pwd_hist_lock" = false ]
    if contains $PWD $$dir_hist
      set -e $dir_hist[1][(contains -i $PWD $$dir_hist)]
    end
    set $dir_hist $$dir_hist $PWD
    set -g dir_hist_val (count $$dir_hist)
  end
end

function __capture_cd_prev -d 'Change to previous directory, press H in NORMAL mode.'
  if [ $dir_hist_val -gt 1 ]
    set dir_hist_val (expr $dir_hist_val - 1)
    set pwd_hist_lock true
    cd $$dir_hist[1][$dir_hist_val]
    commandline -f repaint
  end
end

function __capture_cd_next -d 'Change to next directory, press L in NORMAL mode.'
  if [ $dir_hist_val -lt (count $$dir_hist) ]
    set dir_hist_val (expr $dir_hist_val + 1)
    set pwd_hist_lock true
    cd $$dir_hist[1][$dir_hist_val]
    commandline -f repaint
  end
end

function d -d 'List directory history, jump to directory in list with d <number>'
  set -l num_items (expr (count $$dir_hist) - 1)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Directory history is empty. '(set_color normal)'It will be created automatically.'
    return
  end
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    cd $$dir_hist[1][(expr $num_items - $argv[1])]
  else
    for i in (seq $num_items)
      if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
        set_color normal
      else
        set_color $capture_colors[4]
      end
      echo '▶' (expr $num_items - $i)\t$$dir_hist[1][$i] | sed "s|$HOME|~|"
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $capture_cursors[2]
    set input_length (expr length (expr $num_items - 1))
    read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[5])" ♻ Goto [e|0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[5])' -n $input_length -l dir_num
    switch $dir_num
      case (seq 0 (expr $num_items - 1))
        cd $$dir_hist[1][(expr $num_items - $dir_num)]
      case 'e'
        read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[5])" ♻ Erase [0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[5])' -n $input_length -l dir_num
        set -e $dir_hist[1][(expr $num_items - $dir_num)] 2> /dev/null
        set dir_hist_val (count $$dir_hist)
        tput cuu1
    end
    for i in (seq (expr $num_items + 1))
      tput cuu1
    end
    tput ed
    tput cuu1
  end
  set pcount (expr $pcount - 1)
  set no_prompt_hist 'T'
end

####################
# => Command history
####################
function __capture_create_cmd_hist -e fish_prompt -d 'Create command history without duplicates'
  if [ $_ = 'fish' ]
    set -l IFS ''
    set -l cmd (echo $history[1] | fish_indent | expand -t 4)
    # Create prompt history
    if begin
        [ $pcount -gt 0 ]
        and [ $no_prompt_hist = 'F' ]
      end
      set prompt_hist[$pcount] $cmd
    else
      set no_prompt_hist 'F'
    end
    set pcount (expr $pcount + 1)
    # Create command history
    if not begin
        expr $cmd : '[cdms] ' > /dev/null
        or contains $cmd $capture_nocmdhist
      end
      if contains $cmd $$cmd_hist
        set -e $cmd_hist[1][(contains -i $cmd $$cmd_hist)]
      end
      set $cmd_hist $$cmd_hist $cmd
    end
  end
  set fish_bind_mode insert
  #echo -n \a
  __capture_urgency
end

function c -d 'List command history, load command from prompt with c <prompt number>'
  set -l num_items (count $$cmd_hist)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Command history is empty. '(set_color normal)'It will be created automatically.'
    return
  end
  for i in (seq $num_items)
    if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
      set_color normal
    else
      set_color $capture_colors[4]
    end
    echo -n '▶ '(expr $num_items - $i)
    set -l item (echo $$cmd_hist[1][$i])
    echo -n \t$item\n
  end
  if [ $num_items -eq 1 ]
    set last_item ''
  else
    set last_item '-'(expr $num_items - 1)
  end
  echo -en $capture_cursors[4]
  set input_length (expr length (expr $num_items - 1))
  read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[9])" ↩ Exec [e|0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[9])' -n $input_length -l cmd_num
  switch $cmd_num
    case (seq 0 (expr $num_items - 1))
      commandline $$cmd_hist[1][(expr $num_items - $cmd_num)]
      echo $$cmd_hist[1][(expr $num_items - $cmd_num)] | xsel
      for i in (seq (count (echo $$cmd_hist\n)))
        tput cuu1
      end
    case 'e'
      read -p 'echo -n (set_color -b $capture_colors[2] $capture_colors[9])" ↩ Erase [0"$last_item"] "(set_color -b normal $capture_colors[2])" "(set_color $capture_colors[9])' -n $input_length -l cmd_num
      for i in (seq (count (echo $$cmd_hist\n)))
        tput cuu1
      end
      tput cuu1
      set -e $cmd_hist[1][(expr $num_items - $cmd_num)] 2> /dev/null
  end
  tput ed
  tput cuu1
  set pcount (expr $pcount - 1)
  set no_prompt_hist 'T'
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
  if [ $capture_first_segment -eq 1 ]
    set_color $capture_color_bg_next
    set_color -r
    echo ''
    set_color normal
    set -g $capture_first_segment 0
  end
  set_color -b $capture_color_bg_next
  echo $argv
  set -g capture_color_bg_last $capture_color_bg_next
end

################################
# => Append right prompt segment
################################
function __capture_append_right_prompt_segment -d 'Append a segment to the right prompt'
  set_color $capture_color_bg_next
  echo ''
  set_color -b $capture_color_bg_next
  echo $argv
end


########################
# => Virtual Env segment
########################
function __capture_prompt_virtual_env -d 'Return the current virtual env name'
  if set -q VIRTUAL_ENV
    set -g capture_color_bg_next $capture_color_bg_virtual_env
    set_color $capture_color_fg_virtual_env
    echo -n ' '(basename "$VIRTUAL_ENV")' '
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
    if [ $symbols_style = 'symbols' ]
      switch $pwd_style
        case short
          set user_host " $USER@"(hostname -s)':'
        case long
          set user_host " $USER@"(hostname -f)':'
      end
    else
      set user_host " $USER@"(hostname -i)':'
    end
  end
  if [ (count $capture_prompt_error) != 1 ]
    switch $pwd_style
      case short
        echo -n $user_host(prompt_pwd)' '
      case long
        echo -n $user_host(pwd)' '
    end
  else
    echo -n " $capture_prompt_error "
    set -e capture_prompt_error[1]
  end
end

######################
# => Bind-mode segment
######################
function __capture_prompt_bindmode -d 'Displays the current mode'
  switch $fish_bind_mode
    case default
      set capture_current_bindmode_color $capture_colors[10]
      echo -en $capture_cursors[1]
    case insert
      set capture_current_bindmode_color $capture_colors[5]
      echo -en $capture_cursors[2]
      if [ "$pwd_hist_lock" = true ]
        set pwd_hist_lock false
        __capture_create_dir_hist
      end
    case visual
      set capture_current_bindmode_color $capture_colors[8]
      echo -en $capture_cursors[3]
  end
  if [ (count $capture_prompt_error) -eq 1 ]
    set capture_current_bindmode_color $capture_colors[7]
  end
  set_color -b $capture_current_bindmode_color $capture_colors[1]
  switch $pwd_style
    case short long
      echo -n " $pcount "
  end
  set_color -b normal $capture_current_bindmode_color
end

####################
# => Symbols segment
####################
function __capture_prompt_left_symbols -d 'Display symbols'
    set -l symbols_urgent 'F'
    #set -l symbols (set_color -b $capture_colors[2])''

    set -l jobs (jobs | wc -l | tr -d '[:space:]')
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

    if [ $symbols_style = 'symbols' ]
        if [ $capture_session_current != '' ]
            set symbols $symbols(set_color -o $capture_colors[8])' ✻'
            set symbols_urgent 'T'
        end
        if contains $PWD $bookmarks
            set symbols $symbols(set_color -o $capture_colors[10])' ⌘'
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $capture_colors[9])' V'
            set symbols_urgent 'T'
        end
        if set -q -x RANGER_LEVEL
            set symbols $symbols(set_color -o $capture_colors[9])' R'
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color -o $capture_colors[11])' ⚙'
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $capture_colors[6])' '
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color -o $capture_colors[4])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color -o $capture_colors[8])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols' ⚔'
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color -o $capture_colors[5])' ⚑'
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color -o $capture_colors[12])' ✔'
        else
            set symbols $symbols(set_color -o $capture_colors[7])' ✘'
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $capture_colors[6])' ⚡'
            set symbols_urgent 'T'
        end
    else
        if [ $capture_session_current != '' ] 2> /dev/null
            set symbols $symbols(set_color $capture_colors[8])' '(expr (count $capture_sessions) - (contains -i $capture_session_current $capture_sessions))
            set symbols_urgent 'T'
        end
        if contains $PWD $bookmarks
            set symbols $symbols(set_color $capture_colors[10])' '(expr (count $bookmarks) - (contains -i $PWD $bookmarks))
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $capture_colors[9])' V'(set_color normal)(set_color -b $capture_colors[2])
            set symbols_urgent 'T'
        end
        if set -q -x RANGER_LEVEL
            set symbols $symbols(set_color $capture_colors[9])' '$RANGER_LEVEL
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color $capture_colors[11])' '$jobs
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $capture_colors[6])' '(set_color normal)(set_color -b $capture_colors[2])
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color $capture_colors[4])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color $capture_colors[8])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols" $todo"
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color $capture_colors[5])" $appointments"
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color $capture_colors[12])' '$last_status
        else
            set symbols $symbols(set_color $capture_colors[7])' '$last_status
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $capture_colors[6])' ⚡'
            set symbols_urgent 'T'
        end
    end
    set symbols $symbols(set_color $capture_colors[2])' '(set_color normal)(set_color $capture_colors[2])
    switch $pwd_style
        case none
            if test $symbols_urgent = 'T'
                set symbols (set_color -b $capture_colors[2])''(set_color normal)(set_color $capture_colors[2])
            else
                set symbols ''
            end
    end
    echo -n $symbols
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
  set -g EDITOR vi
end

# Source config file
if [ -e $capture_config ]
  source $capture_config
end

# Don't save in command history
if not set -q capture_nocmdhist
  set -U capture_nocmdhist 'c' 'd' 'll' 'ls' 'm' 's'
end

# Set PWD segment style
if not set -q capture_pwdstyle
  set -U capture_pwdstyle short long none
end
set pwd_style $capture_pwdstyle[1]

# Cd to newest bookmark if this is a login shell
if not begin
    set -q -x LOGIN
    or set -q -x RANGER_LEVEL
    or set -q -x VIM
  end 2> /dev/null
  if set -q bookmarks[1]
    cd $bookmarks[1]
  end
end
set -x LOGIN $USER

###############################################################################
# => Left prompt
###############################################################################

function fish_prompt -d 'Write out the left prompt of the capture theme'
  set -g last_status $status
  set -g first_segment 1
  echo -n -s (__capture_append_left_prompt_segment (__capture_prompt_pwd)) \
             (set_color normal)(set_color $capture_color_bg_last)' '(set_color normal)
#  echo -n -s (__capture_append_left_prompt_segment (__capture_prompt_virtual_env)) \
#             (__capture_append_left_prompt_segment (__capture_prompt_pwd)) \
#             (__capture_append_left_prompt_segment (__capture_prompt_left_symbols)) \
#             (set_color normal)(set_color $capture_color_bg_last)' '(set_color normal)
  #echo -n -s (__capture_prompt_bindmode) (__capture_prompt_virtual_env) (__capture_prompt_pwd) (__capture_prompt_left_symbols) ' ' (set_color normal)
end

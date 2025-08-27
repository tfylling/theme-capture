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
set -U capture_color_palette_silver cdcdcd
set -U capture_color_palette_boulder 777777
set -U capture_color_palette_mine_shaft 212121
set -U capture_color_palette_bright_red af0000
set -U capture_color_palette_red ff0000
set -U capture_color_palette_sangria 8f0006
set -U capture_color_palette_venetian_red 6e0019
set -U capture_color_palette_pirate_gold ce8c00
set -U capture_color_palette_nutmeg_wood_finish 6d4a00
set -U capture_color_palette_yellow ffff00
set -U capture_color_palette_limeade 859900
set -U capture_color_palette_fun_green 006d4a
set -U capture_color_palette_crusoe 004d00
set -U capture_color_palette_jungle_green 2aa198
set -U capture_color_palette_river_bed 445659
set -U capture_color_palette_bahama_blue 006d8f
set -U capture_color_palette_regal_blue 004b6e
set -U capture_color_palette_blue_marguerite 6c71c4
set -U capture_color_palette_black 000000

set -U capture_color_bg_git_commit $capture_color_palette_jungle_green
set -U capture_color_fg_git_commit $capture_color_palette_black
set -U capture_color_bg_git_position $capture_color_palette_blue_marguerite
set -U capture_color_fg_git_position $capture_color_palette_black
set -U capture_color_bg_git_branch $capture_color_palette_river_bed
set -U capture_color_fg_git_branch $capture_color_palette_silver

set -U capture_colors     000000 083743 445659 fdf6e3 2990b5 cb4b16 dc121f af005f 6c71c4 268bd2 2aa198 859900
set -U capture_colors_dim 000000 062932 334143 beb9aa 1f6c88 983811 a50e17 830047 515593 1d689e 207972 647300
#                         1 1     2      3      4      5      6      7      8      9      10     11     12
#                         black  dark_gray light_gray white yellow orange red magenta violet blue cyan green

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


####################
# => Color functions
####################
function __capture_set_color_palette -d 'Set the color palette according to mode'
  switch $fish_bind_mode
    case default
      __capture_set_color_palette_normal
    case insert
      __capture_set_color_palette_insert
    case replace_one replace-one
      __capture_set_color_palette_replace
    case visual
      __capture_set_color_palette_visual
  end
  __capture_reset_colors
end

function __capture_set_color_palette_normal -d 'Set color palette for normal mode'
  set -U capture_color_bg_theme_primary $capture_color_palette_limeade
  set -U capture_color_fg_theme_primary $capture_color_palette_crusoe
  set -U capture_color_bg_theme_secondary $capture_color_palette_crusoe
  set -U capture_color_fg_theme_secondary $capture_color_palette_limeade
  set -U capture_color_bg_theme_contrast $capture_color_palette_silver
  set -U capture_color_fg_theme_contrast $capture_color_palette_crusoe
  set -U capture_color_ok $capture_color_palette_limeade
  set -U capture_color_error $capture_color_palette_red
  set -U capture_color_error_contrast $capture_color_palette_yellow
end

function __capture_set_color_palette_insert -d 'Set color palette for insert mode'
  if [ $USER = 'root' ]
    set -U capture_color_bg_theme_primary $capture_color_palette_sangria
    set -U capture_color_bg_theme_secondary $capture_color_palette_venetian_red
  else
    set -U capture_color_bg_theme_primary $capture_color_palette_bahama_blue
    set -U capture_color_bg_theme_secondary $capture_color_palette_regal_blue
  end
  set -U capture_color_fg_theme_primary $capture_color_palette_silver
  set -U capture_color_fg_theme_secondary $capture_color_palette_silver
  set -U capture_color_bg_theme_contrast $capture_color_palette_silver
  set -U capture_color_fg_theme_contrast $capture_color_bg_theme_primary
  set -U capture_color_ok $capture_color_palette_limeade
  set -U capture_color_error $capture_color_palette_red
  set -U capture_color_error_contrast $capture_color_palette_yellow
end

function __capture_set_color_palette_replace -d 'Set color palette for replace mode'
  set -U capture_color_bg_theme_primary $capture_color_palette_bright_red
  set -U capture_color_fg_theme_primary $capture_color_palette_silver
  set -U capture_color_bg_theme_secondary $capture_color_palette_mine_shaft
  set -U capture_color_fg_theme_secondary $capture_color_palette_boulder
  set -U capture_color_bg_theme_contrast $capture_color_palette_silver
  set -U capture_color_fg_theme_contrast $capture_color_palette_bright_red
  set -U capture_color_ok $capture_color_palette_limeade
  set -U capture_color_error $capture_color_palette_red
  set -U capture_color_error_contrast $capture_color_palette_yellow
end

function __capture_set_color_palette_visual -d 'Set color palette for visual mode'
  set -U capture_color_bg_theme_primary $capture_color_palette_pirate_gold
  set -U capture_color_fg_theme_primary $capture_color_palette_nutmeg_wood_finish
  set -U capture_color_bg_theme_secondary $capture_color_palette_nutmeg_wood_finish
  set -U capture_color_fg_theme_secondary $capture_color_palette_pirate_gold
  set -U capture_color_bg_theme_contrast $capture_color_palette_silver
  set -U capture_color_fg_theme_contrast $capture_color_palette_nutmeg_wood_finish
  set -U capture_color_ok $capture_color_palette_limeade
  set -U capture_color_error $capture_color_palette_red
  set -U capture_color_error_contrast $capture_color_palette_yellow
end

function __capture_reset_colors -d 'Reset colors when primary definitions change'
    set -U capture_color_bg_os $capture_color_bg_theme_contrast
    set -U capture_color_fg_os $capture_color_fg_theme_contrast
    set -U capture_color_fg_ok_text $capture_color_ok
    set -U capture_color_bg_ok_text $capture_color_bg_theme_contrast
    set -U capture_color_fg_error_text $capture_color_error
    set -U capture_color_bg_virtual_env $capture_color_fg_theme_primary
    set -U capture_color_fg_virtual_env $capture_color_bg_theme_primary
    set -U capture_color_bg_duration $capture_color_bg_theme_primary
    set -U capture_color_fg_duration $capture_color_fg_theme_primary
    set -U capture_color_bg_return_code_ok $capture_color_bg_theme_contrast
    set -U capture_color_fg_return_code_ok $capture_color_ok
    set -U capture_color_bg_return_code_error $capture_color_error
    set -U capture_color_fg_return_code_error $capture_color_error_contrast
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
# => Git segment (staged vs. unstaged, no color reset)
################

# ---- Glyphs (override in config.fish if you want) ----
# Staged = document-ish, Unstaged = box-ish by default
set -q CAP_GLYPH_GIT      ; or set -g CAP_GLYPH_GIT       ""
set -q CAP_GLYPH_BRANCH   ; or set -g CAP_GLYPH_BRANCH    ""
set -q CAP_GLYPH_TAG      ; or set -g CAP_GLYPH_TAG       ""
set -q CAP_GLYPH_COMMIT   ; or set -g CAP_GLYPH_COMMIT    ""

# staged (index)
set -q CAP_GLYPH_S_ADD    ; or set -g CAP_GLYPH_S_ADD     "󰝒"
set -q CAP_GLYPH_S_MOD    ; or set -g CAP_GLYPH_S_MOD     "󱇧"
set -q CAP_GLYPH_S_DEL    ; or set -g CAP_GLYPH_S_DEL     "󰮘"
set -q CAP_GLYPH_S_REN    ; or set -g CAP_GLYPH_S_REN     "󱪓"

# unstaged (worktree)
set -q CAP_GLYPH_S_ADD    ; or set -g CAP_GLYPH_S_ADD     ""
set -q CAP_GLYPH_W_MOD    ; or set -g CAP_GLYPH_W_MOD     "󱇨"
set -q CAP_GLYPH_W_DEL    ; or set -g CAP_GLYPH_W_DEL     "󱀷"
set -q CAP_GLYPH_W_REN    ; or set -g CAP_GLYPH_W_REN     "󱪔"

# misc
set -q CAP_GLYPH_AHEAD    ; or set -g CAP_GLYPH_AHEAD     ""
set -q CAP_GLYPH_BEHIND   ; or set -g CAP_GLYPH_BEHIND    ""
set -q CAP_GLYPH_UNMERGED ; or set -g CAP_GLYPH_UNMERGED  ""
set -q CAP_GLYPH_UNTRACK  ; or set -g CAP_GLYPH_UNTRACK   ""
set -q CAP_GLYPH_STASH    ; or set -g CAP_GLYPH_STASH     ""

# Ahead/behind: prints two lines: AHEAD\nBEHIND
function __capture_is_git_ahead_or_behind -d 'Check if there are unpulled or unpushed commits'
    set -l ab (command git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
    if test $status -eq 0 -a -n "$ab"
        set -l parts (string split ' ' -- $ab)
        echo $parts[2]
        echo $parts[1]
    else
        echo 0
        echo 0
    end
end

# File status counts (order):
# 1 s_add  2 s_mod  3 s_del  4 s_ren  5 w_mod  6 w_del  7 w_ren  8 unmerged  9 untracked
function __capture_git_status -d 'Check git status (staged vs. unstaged)'
    set -l s_add 0; set -l s_mod 0; set -l s_del 0; set -l s_ren 0
    set -l w_mod 0; set -l w_del 0; set -l w_ren 0
    set -l unmerged 0; set -l untracked 0

    for line in (command git status --porcelain=v1 2>/dev/null)
        # Untracked
        if string match -rq '^\?\?' -- $line
            set untracked (math $untracked + 1)
            continue
        end

        set -l x (string sub -s 1 -l 1 -- $line)  # index (staged)
        set -l y (string sub -s 2 -l 1 -- $line)  # worktree (unstaged)

        # Conflicted paths (count once)
        if test "$x" = U -o "$y" = U; or contains -- "$x$y" AA DD UU AU UA DU UD
            set unmerged (math $unmerged + 1)
            continue
        end

        # Staged (index) side
        switch $x
            case A
                set s_add (math $s_add + 1)
            case M T
                set s_mod (math $s_mod + 1)
            case D
                set s_del (math $s_del + 1)
            case R
                set s_ren (math $s_ren + 1)
        end

        # Unstaged (worktree) side
        switch $y
            case M T
                set w_mod (math $w_mod + 1)
            case D
                set w_del (math $w_del + 1)
            case R
                set w_ren (math $w_ren + 1)
        end
    end

    echo -n $s_add\n$s_mod\n$s_del\n$s_ren\n$w_mod\n$w_del\n$w_ren\n$unmerged\n$untracked
end

# Stash count
function __capture_is_git_stashed -d 'Check if there are stashed commits'
    command git rev-parse --verify --quiet refs/stash >/dev/null 2>&1; or begin
        echo 0
        return
    end
    command git rev-list --walk-reflogs --count refs/stash 2>/dev/null
end

function __capture_prompt_git_symbols -d 'Displays the git symbols'
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return

    set -l git_ahead_behind (__capture_is_git_ahead_or_behind)
    set -l s ( __capture_git_status )
    set -l git_stashed (__capture_is_git_stashed)

    if test (math $git_ahead_behind[1] + $git_ahead_behind[2] + $s[1] + $s[2] + $s[3] + $s[4] + $s[5] + $s[6] + $s[7] + $s[8] + $s[9] + $git_stashed) -eq 0
        echo ' '
        return
    end

    # ahead / behind (leave as-is; you can style these too if you want)
    if test $git_ahead_behind[1] -gt 0
        set_color -o $capture_colors[5]
        echo -n " $CAP_GLYPH_AHEAD $git_ahead_behind[1] "
    end
    if test $git_ahead_behind[2] -gt 0
        set_color -o $capture_colors[5]
        echo -n " $CAP_GLYPH_BEHIND $git_ahead_behind[2] "
    end

    # STAGED (bold/bright)
    if test $s[1] -gt 0  # staged add
        set_color $capture_colors[12]
        echo -n " $CAP_GLYPH_S_ADD $s[1] "
    end
    if test $s[2] -gt 0  # staged mod
        set_color $capture_colors[10]
        echo -n " $CAP_GLYPH_S_MOD $s[2] "
    end
    if test $s[3] -gt 0  # staged del
        set_color $capture_colors[7]
        echo -n " $CAP_GLYPH_S_DEL $s[3] "
    end
    if test $s[4] -gt 0  # staged ren
        set_color $capture_colors[8]
        echo -n " $CAP_GLYPH_S_REN $s[4] "
    end

    # UNSTAGED (dim/faint)
    if test $s[5] -gt 0  # unstaged mod
        set_color $capture_colors_dim[10]
        echo -n " $CAP_GLYPH_W_MOD $s[5] "
    end
    if test $s[6] -gt 0  # unstaged del
        set_color $capture_colors_dim[7]
        echo -n " $CAP_GLYPH_W_DEL $s[6] "
    end
    if test $s[7] -gt 0  # unstaged ren
        set_color $capture_colors_dim[8]
        echo -n " $CAP_GLYPH_W_REN $s[7] "
    end

    # other (unchanged intensity; tweak if you want)
    if test $s[8] -gt 0  # unmerged
        set_color -o $capture_colors[9]
        echo -n " $CAP_GLYPH_UNMERGED $s[8] "
    end
    if test $s[9] -gt 0  # untracked
        set_color -o $capture_colors[4]
        echo -n " $CAP_GLYPH_UNTRACK $s[9] "
    end
    if test $git_stashed -gt 0
        set_color -o $capture_colors[11]
        echo -n " $CAP_GLYPH_STASH $git_stashed "
    end

    echo ' '
end

# Branch/position/commit label, then symbols; no color reset
function __capture_prompt_git_branch -d 'Return the current branch name'
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return

    set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -n "$branch"
        set -g capture_color_bg_next $capture_color_bg_git_branch
        set_color $capture_color_fg_git_branch
        echo -n " $CAP_GLYPH_GIT $CAP_GLYPH_BRANCH $branch"
    else
        set -l position (command git describe --contains --all HEAD 2>/dev/null)
        if test -n "$position"
            set -g capture_color_bg_next $capture_color_bg_git_position
            set_color $capture_color_fg_git_position
            set -l pretty (string replace -r '^tags/' "$CAP_GLYPH_TAG " -- $position)
            echo -n " $CAP_GLYPH_GIT $pretty"
        else
            set -l commit (command git rev-parse --short=7 HEAD 2>/dev/null)
            if test -n "$commit"
                set -g capture_color_bg_next $capture_color_bg_git_commit
                set_color $capture_color_fg_git_commit
                echo -n " $CAP_GLYPH_GIT $CAP_GLYPH_COMMIT $commit"
            end
        end
    end

    __capture_prompt_git_symbols
end

###############
# => OS segment
###############
function __capture_prompt_os_icon -d 'Displays icon for current OS'
  set -g capture_color_bg_next $capture_color_bg_os
  set -l os (cat /etc/os-release|sed -n -e "s/^ID=//p")
  if [ $os = "ubuntu" ]
    set os_icon ''
  else if [ $os = "debian" ]
    set os_icon ''
  else
    set os_icon ''
  end
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
  __capture_set_color_palette
  echo -n -s \
             (__capture_append_left_prompt_segment (__capture_prompt_os_icon)) \
             (__capture_append_left_prompt_segment (__capture_prompt_virtual_env)) \
             (__capture_append_left_prompt_segment (__capture_prompt_pwd)) \
             (__capture_append_left_prompt_segment (__capture_prompt_symbols)) \
             (set_color normal)(set_color $capture_color_bg_last)' '(set_color normal)
# if [ $USER = 'root' ]
#   echo -e -n " \b"
# end
end

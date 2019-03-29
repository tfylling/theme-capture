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
# => Prompt
###############################################################################

function fish_right_prompt -d 'Write out the right prompt of the capture theme'
  echo -n -s \
             (__capture_append_right_prompt_segment (__capture_prompt_git_branch)) \
             (__capture_append_right_prompt_segment (__capture_cmd_duration)) \
             (__capture_append_right_prompt_segment (__capture_return_code)) \
             (set_color normal)
end

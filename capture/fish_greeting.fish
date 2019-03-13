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
# sections:
#   -> Welcome message
#
###############################################################################

####################
# => Welcome message
####################
function fish_greeting -d 'Show greeting in login shell.'
  if not set -q capture_nogreeting
    if begin
      not set -q -x LOGIN
      and not set -q -x RANGER_LEVEL
      and not set -q -x VIM
      end
      echo This is (set_color -b $capture_colors[2] \
      $capture_colors[10])capture(set_color normal) theme for fish, a theme for nerds.
      echo Type (set_color -b $capture_colors[2] $capture_colors[6])»capture_help«(set_color normal) in order to see how you can speed up your workflow.
      end
  end
end

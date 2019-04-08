#set fish_key_bindings fish_vi_key_bindings
bind '#' __capture_toggle_symbols
bind -M visual '#' __capture_toggle_symbols
bind ' ' __capture_toggle_pwd
bind -M visual ' ' __capture_toggle_pwd
bind L __capture_cd_next
bind H __capture_cd_prev
bind m mark
bind M unmark
bind . __capture_edit_commandline
bind -M insert \r __capture_preexec
bind \r __capture_preexec
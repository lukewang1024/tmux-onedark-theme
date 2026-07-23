#!/bin/bash
# tmux-onedark-theme — a One Dark color scheme for tmux.
#
# Beyond the static palette it can follow the system light/dark appearance and
# adapt to the terminal's own colors:
#   * @onedark_adaptive = off | light | full — a light/dark-adaptive palette
#     (see README). @onedark_appearance (auto|light|dark) overrides detection.
#   * Activity/bell shown as a recolored #I/#W separator mark (activity ->
#     yellow, bell -> red) instead of the default reverse-video banner.
#
# Safe for an out-of-shell re-apply (e.g. an appearance watcher firing on
# macOS's AppleInterfaceThemeChangedNotification): an explicit PATH so tmux
# resolves under launchd, and a refresh-client at the end so the repaint lands
# immediately instead of on the next attach.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"
command -v tmux >/dev/null 2>&1 || exit 0
tmux has-session >/dev/null 2>&1 || exit 0

get() {
   local option=$1
   local default_value=$2
   local option_value="$(tmux show-option -gqv "$option")"

   if [ -z "$option_value" ]; then
      echo "$default_value"
   else
      echo "$option_value"
   fi
}

set() {
   local option=$1
   local value=$2
   tmux set-option -gq "$option" "$value"
}

setw() {
   local option=$1
   local value=$2
   tmux set-window-option -gq "$option" "$value"
}

# --- palette: the only thing that changes between modes ----------------------
mode=$(get "@onedark_adaptive" "off")
case "$mode" in light|full) follow=yes ;; *) follow=no ;; esac

appearance=$(get "@onedark_appearance" "auto")
if [ "$follow" = yes ] && [ "$appearance" = auto ]; then
   appearance=dark
   if [ "$(uname)" = Darwin ]; then
      [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = Dark ] || appearance=light
   else
      case "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" in
         *dark*) : ;; *) appearance=light ;;
      esac
   fi
fi

if [ "$follow" = yes ] && [ "$appearance" = light ]; then
   # Atom One Light
   onedark_black="#fafafa"; onedark_white="#383a42"; onedark_visual_grey="#e5e5e6"
   onedark_comment_grey="#a0a1a7"; onedark_green="#50a14f"; onedark_yellow="#c18401"
   onedark_red="#e45649"; onedark_blue="#4078f2"
else
   # One Dark
   onedark_black="#282c34"; onedark_blue="#61afef"; onedark_yellow="#e5c07b"
   onedark_red="#e06c75"; onedark_white="#aab2bf"; onedark_green="#98c379"
   onedark_visual_grey="#3e4452"; onedark_comment_grey="#5c6370"
fi

if [ "$mode" = full ]; then
   onedark_green=$(get "@onedark_accent" "colour2")   # session/host pill accent
   onedark_yellow=colour3                              # warn:  activity mark/cap
   onedark_red=colour1                                 # alert: bell mark/cap
   onedark_blue=colour4
fi

# Powerline separators. printf octal keeps this working under bash 3.2 (no \u)
# and any locale; set-option stores the bytes verbatim.
pl_rf=$(printf '\356\202\260')   # U+E0B0  right, filled
pl_rt=$(printf '\356\202\261')   # U+E0B1  right, thin
pl_lf=$(printf '\356\202\262')   # U+E0B2  left,  filled
pl_lt=$(printf '\356\202\263')   # U+E0B3  left,  thin

set "status" "on"
set "status-justify" "left"

set "status-left-length" "100"
set "status-right-length" "150"
set "status-right-attr" "none"

set "message-fg" "$onedark_white"
set "message-bg" "$onedark_black"

set "message-command-fg" "$onedark_white"
set "message-command-bg" "$onedark_black"

set "status-attr" "none"
set "status-left-attr" "none"

setw "window-status-fg" "$onedark_black"
setw "window-status-bg" "$onedark_black"
setw "window-status-attr" "none"

# Keep activity/bell tabs neutral (no reverse-video banner); the indicator is
# the recolored separator mark in window-status-format below.
setw "window-status-activity-style" "fg=$onedark_white,bg=$onedark_black,none"
setw "window-status-bell-style" "fg=$onedark_white,bg=$onedark_black,none"

setw "window-status-separator" ""

set "window-style" "fg=$onedark_comment_grey"
set "window-active-style" "fg=$onedark_white"

set "pane-border-fg" "$onedark_white"
set "pane-border-bg" "$onedark_black"
set "pane-active-border-fg" "$onedark_green"
set "pane-active-border-bg" "$onedark_black"

set "display-panes-active-colour" "$onedark_yellow"
set "display-panes-colour" "$onedark_blue"

set "status-bg" "$onedark_black"
set "status-fg" "$onedark_white"

set "@prefix_highlight_fg" "$onedark_black"
set "@prefix_highlight_bg" "$onedark_green"
set "@prefix_highlight_copy_mode_attr" "fg=$onedark_black,bg=$onedark_green"
set "@prefix_highlight_output_prefix" "  "

status_widgets=$(get "@onedark_widgets")
time_format=$(get "@onedark_time_format" "%R")
date_format=$(get "@onedark_date_format" "%d/%m/%Y")

# activity -> yellow, bell -> red, else normal: recolors the #I/#W separator.
mark="#{?window_bell_flag,$onedark_red,#{?window_activity_flag,$onedark_yellow,$onedark_white}}"

set "status-right" "#[fg=$onedark_white,bg=$onedark_black,nounderscore,noitalics]${time_format} ${pl_lt} ${date_format} #[fg=$onedark_visual_grey,bg=$onedark_black]${pl_lf}#[fg=$onedark_visual_grey,bg=$onedark_visual_grey]${pl_lf}#[fg=$onedark_white, bg=$onedark_visual_grey]${status_widgets} #[fg=$onedark_green,bg=$onedark_visual_grey,nobold,nounderscore,noitalics]${pl_lf}#[fg=$onedark_black,bg=$onedark_green,bold] #h #[fg=$onedark_yellow, bg=$onedark_green]${pl_lf}#[fg=$onedark_red,bg=$onedark_yellow]${pl_lf}"
set "status-left" "#[fg=$onedark_black,bg=$onedark_green,bold] #S #{prefix_highlight}#[fg=$onedark_green,bg=$onedark_black,nobold,nounderscore,noitalics]${pl_rf}"

set "window-status-format" "#[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics]${pl_rf}#[fg=$onedark_white,bg=$onedark_black] #I #[fg=${mark}]${pl_rt}#[fg=$onedark_white] #W #[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics]${pl_rf}"
set "window-status-current-format" "#[fg=$onedark_black,bg=$onedark_visual_grey,nobold,nounderscore,noitalics]${pl_rf}#[fg=$onedark_white,bg=$onedark_visual_grey,nobold] #I ${pl_rt} #W #[fg=$onedark_visual_grey,bg=$onedark_black,nobold,nounderscore,noitalics]${pl_rf}"

# The widgets in status-right come from other plugins (battery/cpu/
# prefix-highlight) that tpm may source after this theme; re-run them so their
# format placeholders resolve, then refresh each client's status line so a
# re-apply (e.g. from an appearance watcher) repaints immediately.
plug="$HOME/.local/share/tmux/plugins"
for p in tmux-prefix-highlight/prefix_highlight tmux-battery/battery tmux-cpu/cpu; do
   [ -x "$plug/$p.tmux" ] && "$plug/$p.tmux" >/dev/null 2>&1
done
for c in $(tmux list-clients -F '#{client_name}' 2>/dev/null); do
   tmux refresh-client -S -t "$c" 2>/dev/null
done

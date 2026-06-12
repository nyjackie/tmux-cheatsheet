#!/usr/bin/env bash
# ============================================================================
# tmux-cheatsheet — plugin entry point
#
# Adds a clickable "⌨ Keys" module to the right side of the status bar.
# Clicking it (or pressing prefix + C-h by default) opens a popup with a
# shortcut cheatsheet.
#
# Requires: tmux >= 3.2 (for display-popup and status ranges)
#           `set -g mouse on` in your tmux.conf for click support
# ============================================================================

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read a global tmux option, falling back to a default value.
get_option() {
  local value
  value="$(tmux show-option -gqv "$1")"
  echo "${value:-$2}"
}

main() {
  local label key action target status_right module

  label="$(get_option "@cheatsheet_label" " ⌨ Keys ")"
  key="$(get_option "@cheatsheet_key" "C-h")"

  # "menu"  -> interactive, clickable menu that runs commands (default)
  # "popup" -> read-only scrollable cheatsheet
  action="$(get_option "@cheatsheet_click_action" "menu")"
  if [[ "$action" == "popup" ]]; then
    target="$CURRENT_DIR/scripts/show_cheatsheet.sh"
  else
    target="$CURRENT_DIR/scripts/show_menu.sh"
  fi

  # --------------------------------------------------------------------
  # 1. Clickable status bar module
  #
  # We wrap the label in a named "user range". When the status bar is
  # clicked, tmux tells us which range was hit via #{mouse_status_range},
  # so other things on your status-right keep working normally.
  # --------------------------------------------------------------------
  module="#[range=user|cheatsheet]#[fg=colour235,bg=colour114,bold]${label}#[default]#[norange]"

  status_right="$(tmux show-option -gv status-right)"
  if [[ "$status_right" != *"range=user|cheatsheet"* ]]; then
    tmux set-option -g status-right "${module} ${status_right}"
  fi

  # Left-click on the module -> open the menu (or popup, per the option).
  tmux bind-key -n MouseDown1StatusRight \
    if-shell -F '#{==:#{mouse_status_range},cheatsheet}' \
    "run-shell '$target'"

  # --------------------------------------------------------------------
  # 2. Keyboard shortcut (default: prefix + C-h)
  # --------------------------------------------------------------------
  tmux bind-key "$key" run-shell "$target"
}

main

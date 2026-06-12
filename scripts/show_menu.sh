#!/usr/bin/env bash
# ============================================================================
# show_menu.sh — clickable shortcut menus using tmux's native display-menu
#
# Every item shows the real keybinding for reference AND runs the actual
# command when clicked (or when its menu key is pressed).
#
# Navigation: this script calls itself with a category argument to open
# submenus (run-shell from a menu item is async, so the previous menu has
# already closed by the time the next one opens).
#
# Requires: tmux >= 3.0 (display-menu), `set -g mouse on` for clicking.
# ============================================================================

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SELF="$CURRENT_DIR/show_menu.sh"
POPUP="$CURRENT_DIR/show_cheatsheet.sh"

# All menus are centered; "-T" sets the title shown in the border.
MENU=(tmux display-menu -x C -y C)

menu_main() {
  "${MENU[@]}" -T " ⌨ tmux shortcuts " \
    "Panes ▸"      p "run-shell '$SELF panes'" \
    "Windows ▸"    w "run-shell '$SELF windows'" \
    "Sessions ▸"   s "run-shell '$SELF sessions'" \
    "Copy & misc ▸" c "run-shell '$SELF misc'" \
    "" \
    "Full cheatsheet (read-only)" f "run-shell '$POPUP'" \
    "Close" q ""
}

menu_panes() {
  "${MENU[@]}" -T " Panes — click to run " \
    "Split left │ right   (prefix %)"      v "split-window -h" \
    "Split top ─ bottom   (prefix \")"     h "split-window -v" \
    "Zoom pane            (prefix z)"      z "resize-pane -Z" \
    "Next pane            (prefix o)"      o "select-pane -t :.+" \
    "Swap pane down       (prefix })"      s "swap-pane -D" \
    "Cycle layouts        (prefix Space)"  l "next-layout" \
    "Break into window    (prefix !)"      b "break-pane" \
    "Kill pane            (prefix x)"      x "confirm-before -p 'kill this pane? (y/n)' kill-pane" \
    "" \
    "◀ Back" Left "run-shell '$SELF'"
}

menu_windows() {
  "${MENU[@]}" -T " Windows — click to run " \
    "New window           (prefix c)"      c "new-window" \
    "Rename window        (prefix ,)"      r "command-prompt -I '#W' 'rename-window %%'" \
    "Next window          (prefix n)"      n "next-window" \
    "Previous window      (prefix p)"      p "previous-window" \
    "Window picker        (prefix w)"      w "choose-tree -Zw" \
    "Kill window          (prefix &)"      x "confirm-before -p 'kill this window? (y/n)' kill-window" \
    "" \
    "◀ Back" Left "run-shell '$SELF'"
}

menu_sessions() {
  "${MENU[@]}" -T " Sessions — click to run " \
    "Session picker       (prefix s)"      s "choose-tree -Zs" \
    "Rename session       (prefix \$)"     r "command-prompt 'rename-session %%'" \
    "Next session         (prefix ))"      n "switch-client -n" \
    "Previous session     (prefix ()"      p "switch-client -p" \
    "Detach               (prefix d)"      d "detach-client" \
    "" \
    "◀ Back" Left "run-shell '$SELF'"
}

menu_misc() {
  "${MENU[@]}" -T " Copy mode & misc — click to run " \
    "Enter copy mode      (prefix [)"      c "copy-mode" \
    "Paste buffer         (prefix ])"      p "paste-buffer" \
    "Buffer picker        (prefix =)"      b "choose-buffer -Z" \
    "Command prompt       (prefix :)"      ":" "command-prompt" \
    "Big clock            (prefix t)"      t "clock-mode" \
    "All keybindings      (prefix ?)"      k "list-keys" \
    "" \
    "◀ Back" Left "run-shell '$SELF'"
}

case "${1:-main}" in
  panes)    menu_panes ;;
  windows)  menu_windows ;;
  sessions) menu_sessions ;;
  misc)     menu_misc ;;
  *)        menu_main ;;
esac

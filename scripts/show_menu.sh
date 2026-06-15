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
# Colors use tmux's own #[...] style markup (Catppuccin Mocha truecolor).
# display-menu ignores raw ANSI \e[ codes, so #[fg=#..,bg=#..] is the way.
#
# Requires: tmux >= 3.4 (display-menu + -s/-S/-H styling), `set -g mouse on`.
# ============================================================================

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SELF="$CURRENT_DIR/show_menu.sh"
POPUP="$CURRENT_DIR/show_cheatsheet.sh"

# ---- Catppuccin Mocha — tmux #[...] style markup ---------------------------
CHIP="#[fg=#a6e3a1,bold]"              # green keycap, no chip background
DESC="#[fg=#cdd6f4]"                    # description text
REF="#[fg=#fab387]"                     # prefix-key reference, peach
DIM="#[fg=#7f849c]"                     # back / close, overlay1
ACCENT="#[fg=#cba6f7,bold]"             # mauve accent
BLUE="#[fg=#89b4fa,bold]"               # subtle blue (full cheatsheet)
RST="#[default]"

# All menus: centered, rounded border, themed body/border/selection.
MENU=(tmux display-menu -x C -y C -b rounded
  -s "fg=#cdd6f4,bg=#1e1e2e"
  -S "fg=#cba6f7,bg=#1e1e2e"
  -H "fg=#1e1e2e,bg=#cba6f7,bold")

# chip <key> <description>            -> label: keycap chip + description
chip() { printf '%s %s %s %s%s%s' "$CHIP" "$1" "$RST" "$DESC" "$2" "$RST"; }
# cmd  <key> <description> <prefix>   -> label: chip + description + prefix ref
cmd()  { printf '%s %s %s %s%-20s%sprefix %s%s' "$CHIP" "$1" "$RST" "$DESC" "$2" "$REF" "$3" "$RST"; }

menu_main() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] ⌨ tmux shortcuts " \
    "$(chip p 'Panes ▸')"       p "run-shell '$SELF panes'" \
    "$(chip w 'Windows ▸')"     w "run-shell '$SELF windows'" \
    "$(chip s 'Sessions ▸')"    s "run-shell '$SELF sessions'" \
    "$(chip c 'Copy & misc ▸')" c "run-shell '$SELF misc'" \
    "" \
    "${BLUE} f ${RST} ${BLUE}Full cheatsheet (read-only)${RST}" f "run-shell '$POPUP'" \
    "${DIM} q  Close${RST}" q ""
}

menu_panes() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Panes — click to run " \
    "$(cmd v 'Split left | right' '%')"     v "split-window -h" \
    "$(cmd h 'Split top - bottom' '\"')"    h "split-window -v" \
    "$(cmd z 'Zoom pane'          'z')"     z "resize-pane -Z" \
    "$(cmd o 'Next pane'          'o')"     o "select-pane -t :.+" \
    "$(cmd s 'Swap pane down'     '}')"     s "swap-pane -D" \
    "$(cmd l 'Cycle layouts'      'Space')" l "next-layout" \
    "$(cmd b 'Break into window'  '!')"     b "break-pane" \
    "$(cmd x 'Kill pane'          'x')"     x "confirm-before -p 'kill this pane? (y/n)' kill-pane" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

menu_windows() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Windows — click to run " \
    "$(cmd c 'New window'      'c')" c "new-window" \
    "$(cmd r 'Rename window'   ',')" r "command-prompt -I '#W' 'rename-window %%'" \
    "$(cmd n 'Next window'     'n')" n "next-window" \
    "$(cmd p 'Previous window' 'p')" p "previous-window" \
    "$(cmd w 'Window picker'   'w')" w "choose-tree -Zw" \
    "$(cmd x 'Kill window'     '&')" x "confirm-before -p 'kill this window? (y/n)' kill-window" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

menu_sessions() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Sessions — click to run " \
    "$(cmd s 'Session picker'   's')"  s "choose-tree -Zs" \
    "$(cmd r 'Rename session'   '\$')" r "command-prompt 'rename-session %%'" \
    "$(cmd n 'Next session'     ')')"  n "switch-client -n" \
    "$(cmd p 'Previous session' '(')"  p "switch-client -p" \
    "$(cmd d 'Detach'           'd')"  d "detach-client" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

menu_misc() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Copy mode & misc — click to run " \
    "$(cmd c 'Enter copy mode' '[')" c "copy-mode" \
    "$(cmd p 'Paste buffer'    ']')" p "paste-buffer" \
    "$(cmd b 'Buffer picker'   '=')" b "choose-buffer -Z" \
    "$(cmd : 'Command prompt'  ':')" : "command-prompt" \
    "$(cmd t 'Big clock'       't')" t "clock-mode" \
    "$(cmd l 'All keybindings' '?')" l "list-keys" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

case "${1:-main}" in
  panes)    menu_panes ;;
  windows)  menu_windows ;;
  sessions) menu_sessions ;;
  misc)     menu_misc ;;
  *)        menu_main ;;
esac

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
REF="#[fg=#fab387]"                     # (unused) prefix-key reference, peach
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
# cmd  <description> <prefix>         -> label: description + prefix ref
# The pressable key is rendered by tmux itself as "(key)" on the right (it's the
# menu mnemonic, passed as the field right after this label). We deliberately do
# NOT draw our own keycap on the left, which would just duplicate that "(key)".
# The label must also not END on a #[...] style tag, or this tmux build appends a
# stray ">" marker — so we reset the style before the trailing "prefix X" text
# and end on a plain space.
cmd()  { printf '%s%-20s%sprefix %s ' "$DESC" "$1" "$RST" "$2"; }

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
    "$(cmd 'Split left | right' '%')"     v "split-window -h" \
    "$(cmd 'Split top - bottom' '\"')"    h "split-window -v" \
    "$(cmd 'Zoom pane'          'z')"     z "resize-pane -Z" \
    "$(cmd 'Next pane'          'o')"     o "select-pane -t :.+" \
    "$(cmd 'Swap pane down'     '}')"     s "swap-pane -D" \
    "$(cmd 'Cycle layouts'      'Space')" l "next-layout" \
    "$(cmd 'Break into window'  '!')"     b "break-pane" \
    "$(cmd 'Kill pane'          'x')"     x "confirm-before -p 'kill this pane? (y/n)' kill-pane" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

menu_windows() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Windows — click to run " \
    "$(cmd 'New window'      'c')" c "new-window" \
    "$(cmd 'Rename window'   ',')" r "command-prompt -I '#W' 'rename-window %%'" \
    "$(cmd 'Next window'     'n')" n "next-window" \
    "$(cmd 'Previous window' 'p')" p "previous-window" \
    "$(cmd 'Window picker'   'w')" w "choose-tree -Zw" \
    "$(cmd 'Kill window'     '&')" x "confirm-before -p 'kill this window? (y/n)' kill-window" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

menu_sessions() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Sessions — click to run " \
    "$(cmd 'Session picker'   's')"  s "choose-tree -Zs" \
    "$(cmd 'Rename session'   '\$')" r "command-prompt 'rename-session %%'" \
    "$(cmd 'Next session'     ')')"  n "switch-client -n" \
    "$(cmd 'Previous session' '(')"  p "switch-client -p" \
    "$(cmd 'Detach'           'd')"  d "detach-client" \
    "" \
    "${DIM}◀ Back${RST}" Left "run-shell '$SELF'"
}

menu_misc() {
  "${MENU[@]}" -T "#[fg=#cba6f7,bold] Copy mode & misc — click to run " \
    "$(cmd 'Enter copy mode' '[')" c "copy-mode" \
    "$(cmd 'Paste buffer'    ']')" p "paste-buffer" \
    "$(cmd 'Buffer picker'   '=')" b "choose-buffer -Z" \
    "$(cmd 'Command prompt'  ':')" : "command-prompt" \
    "$(cmd 'Big clock'       't')" t "clock-mode" \
    "$(cmd 'All keybindings' '?')" k "list-keys" \
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

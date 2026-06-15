#!/usr/bin/env bash
# ============================================================================
# render_cheatsheet.sh — prints the cheatsheet content (with ANSI colors)
#
# Customization (set in tmux.conf):
#   set -g @cheatsheet_file "~/.config/tmux/my-keys.txt"  # use your own file
#   set -g @cheatsheet_show_live "on"                     # append real bindings
# ============================================================================

get_option() {
  local value
  value="$(tmux show-option -gqv "$1")"
  echo "${value:-$2}"
}

# ---- Colors — Catppuccin Mocha (24-bit truecolor) --------------------------
B=$'\e[1m'                          # bold
R=$'\e[0m'                          # reset
MAUVE=$'\e[38;2;203;166;247m'       # header / keyword
BLUE=$'\e[38;2;137;180;250m'        # section titles / function
GREEN=$'\e[38;2;166;227;161m'       # keys / string
PEACH=$'\e[38;2;250;179;135m'       # prefix value / constant
TEXT=$'\e[38;2;205;214;244m'        # descriptions
SUB=$'\e[38;2;127;132;156m'         # tips / comments (overlay1)
SURF=$'\e[48;2;49;50;68m'           # keycap background (surface0)
KEYCHIP="${B}${GREEN}${SURF}"       # highlighted key token

# Show the user's actual prefix in the header (e.g. C-b or C-a)
PREFIX="$(tmux show-option -gv prefix)"

# ---- Custom cheatsheet file (optional) -------------------------------------
CUSTOM_FILE="$(get_option "@cheatsheet_file" "")"
if [[ -n "$CUSTOM_FILE" ]]; then
  CUSTOM_FILE="${CUSTOM_FILE/#\~/$HOME}"
  if [[ -r "$CUSTOM_FILE" ]]; then
    cat "$CUSTOM_FILE"
    exit 0
  fi
fi

# ---- Helpers ----------------------------------------------------------------
section() { printf "\n  ${B}${BLUE}%s${R}\n" "$1"; }

# A key gets a "keycap" chip (Surface0 bg); descriptions align to a fixed
# column so they line up no matter how wide the key token is.
row() {
  local k="$1" d="$2" pad
  pad=$(( 22 - ${#k} ))
  (( pad < 1 )) && pad=1
  printf "    ${KEYCHIP} %s ${R}%*s${TEXT}%s${R}\n" "$k" "$pad" "" "$d"
}

# ---- Default cheatsheet ------------------------------------------------------
printf "\n  ${B}${MAUVE}TMUX CHEATSHEET${R}   ${SUB}prefix = ${R}${B}${PEACH}%s${R}${SUB} — press it before every key below${R}\n" \
  "$PREFIX"

section "Sessions"
row "d"           "detach from session"
row "s"           "list / switch sessions"
row "\$"          "rename session"
row "( / )"       "previous / next session"

section "Windows"
row "c"           "create window"
row ","           "rename window"
row "&"           "kill window"
row "n / p"       "next / previous window"
row "0-9"         "jump to window by number"
row "w"           "window picker"

section "Panes"
row "%"           "split vertically (left/right)"
row "\""          "split horizontally (top/bottom)"
row "← ↑ → ↓"     "move between panes"
row "o"           "cycle panes"
row "x"           "kill pane"
row "z"           "toggle pane zoom"
row "{ / }"       "swap pane left / right"
row "Space"       "cycle layouts"
row "q"           "show pane numbers (press # to jump)"
row "!"           "break pane into its own window"

section "Copy mode"
row "["           "enter copy mode"
row "]"           "paste"
row "Space"       "start selection (in copy mode)"
row "Enter"       "copy selection (in copy mode)"
row "/ or ?"      "search forward / backward"
row "q"           "exit copy mode"

section "Misc"
row "t"           "big clock"
row ":"           "command prompt"
row "?"           "list ALL keybindings"
row "r"           "reload config (if bound)"

printf "\n  ${SUB}Tip: set -g @cheatsheet_file to use your own custom list.${R}\n"

# ---- Live bindings (optional) ------------------------------------------------
if [[ "$(get_option "@cheatsheet_show_live" "off")" == "on" ]]; then
  section "Live prefix bindings (from your running tmux)"
  tmux list-keys -N -T prefix 2>/dev/null | sed 's/^/    /'
fi

printf "\n"

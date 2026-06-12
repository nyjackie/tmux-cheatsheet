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

# ---- Colors ----------------------------------------------------------------
B=$'\e[1m'      # bold
D=$'\e[2m'      # dim
C=$'\e[36m'     # cyan  (keys)
Y=$'\e[33m'     # yellow (section titles)
R=$'\e[0m'      # reset

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
section() { printf "\n  %s%s%s\n" "${B}${Y}" "$1" "$R"; }
row()     { printf "    %s%-22s%s %s\n" "$C" "$1" "$R" "$2"; }

# ---- Default cheatsheet ------------------------------------------------------
printf "\n  %sTMUX CHEATSHEET%s   %sprefix = %s — press it before every key below%s\n" \
  "$B" "$R" "$D" "$PREFIX" "$R"

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

printf "\n  %sTip: set -g @cheatsheet_file to use your own custom list.%s\n" "$D" "$R"

# ---- Live bindings (optional) ------------------------------------------------
if [[ "$(get_option "@cheatsheet_show_live" "off")" == "on" ]]; then
  section "Live prefix bindings (from your running tmux)"
  tmux list-keys -N -T prefix 2>/dev/null | sed 's/^/    /'
fi

printf "\n"

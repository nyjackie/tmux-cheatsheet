#!/usr/bin/env bash
# ============================================================================
# show_cheatsheet.sh — opens the cheatsheet in a tmux popup
#
# Falls back to a temporary window if display-popup isn't available
# (tmux < 3.2).
# ============================================================================

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get_option() {
  local value
  value="$(tmux show-option -gqv "$1")"
  echo "${value:-$2}"
}

WIDTH="$(get_option "@cheatsheet_width" "72%")"
HEIGHT="$(get_option "@cheatsheet_height" "85%")"

# Render the cheatsheet and pipe it through `less` so long lists scroll.
#   -R  keep ANSI colors
#   -~  hide the ~ markers past end of file
#   -P  custom status line at the bottom of the pager
CMD="'$CURRENT_DIR/render_cheatsheet.sh' | less -R -~ -P ' j/k scroll · / search · q close '"

# Preferred: floating popup (tmux >= 3.2)
if tmux display-popup -E -w "$WIDTH" -h "$HEIGHT" -T " tmux cheatsheet " "$CMD" 2>/dev/null; then
  exit 0
fi

# Fallback: open in a throwaway window
tmux new-window -n "cheatsheet" "$CMD"

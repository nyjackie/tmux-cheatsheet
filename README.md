# tmux-cheatsheet

A tmux plugin that adds a clickable **⌨ Keys** button to your status bar. Click it (or press `prefix + C-h`) and a popup appears with a scrollable, color-coded shortcut cheatsheet.

## Requirements

- tmux **3.2+** (for `display-popup` and clickable status ranges; older versions fall back to opening a window)
- Mouse support enabled in your config:

```tmux
set -g mouse on
```

## Installation

### With TPM (recommended)

1. Put this folder in `~/.tmux/plugins/tmux-cheatsheet` (or push it to GitHub and reference it as `yourname/tmux-cheatsheet`).
2. Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'yourname/tmux-cheatsheet'
```

3. Press `prefix + I` to install.

### Manual

```bash
git clone <this repo> ~/.tmux/plugins/tmux-cheatsheet
chmod +x ~/.tmux/plugins/tmux-cheatsheet/cheatsheet.tmux \
         ~/.tmux/plugins/tmux-cheatsheet/scripts/*.sh
```

Then add to `~/.tmux.conf` (after your `status-right` is set, so the button is prepended to it):

```tmux
run-shell ~/.tmux/plugins/tmux-cheatsheet/cheatsheet.tmux
```

Reload: `tmux source-file ~/.tmux.conf`

## Usage

- **Click** the `⌨ Keys` label on the right side of the status bar
- Or press `prefix + C-h`
- Inside the popup: `j`/`k` or arrows to scroll, `/` to search, `q` to close

## Options

Set any of these in `~/.tmux.conf` **before** the `run-shell` line:

```tmux
set -g @cheatsheet_label " ⌨ Keys "        # status bar button text
set -g @cheatsheet_key "C-h"               # keyboard shortcut (prefix + key)
set -g @cheatsheet_width "72%"             # popup width
set -g @cheatsheet_height "85%"            # popup height
set -g @cheatsheet_show_live "on"          # append your real bindings (tmux list-keys)
set -g @cheatsheet_file "~/my-keys.txt"    # replace default content with your own file
```

## How it works

- `cheatsheet.tmux` wraps the button label in a tmux *user range* (`#[range=user|cheatsheet]`) and prepends it to `status-right`. A `MouseDown1StatusRight` binding checks `#{mouse_status_range}` so only clicks on the button trigger the popup — the rest of your status bar is untouched.
- `scripts/show_cheatsheet.sh` opens `display-popup` (with a new-window fallback for old tmux).
- `scripts/render_cheatsheet.sh` prints the colored cheatsheet, piped through `less -R` for scrolling and search.

## Interactive menu (clickable commands)

By default, clicking the status button now opens a **native tmux menu** (`display-menu`) instead of the read-only popup. Each item shows the real keybinding *and* runs the actual command when you click it — e.g. clicking "Split left │ right (prefix %)" actually splits the pane.

- Categories open as submenus: Panes ▸, Windows ▸, Sessions ▸, Copy & misc ▸
- "Full cheatsheet (read-only)" inside the menu opens the original scrollable popup
- Destructive actions (kill pane/window) ask for confirmation first

To prefer the read-only popup on click instead:

```tmux
set -g @cheatsheet_click_action "popup"
```

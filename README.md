# tmux-onedark-theme
A dark tmux color scheme for terminals that support [True Color](https://en.wikipedia.org/wiki/Color_depth#True_color_.2824-bit.29), based on [onedark.vim](https://github.com/joshdick/onedark.vim), which is inspired by the [One Dark syntax theme](https://github.com/atom/one-dark-syntax) for the [Atom text editor](https://atom.io). It can also follow the system's light/dark appearance and pick up the terminal's own palette — see [Modes](#modes).

## Why?

I wanted both vim and tmux to share the same color scheme.
I tried [tmuxline.vim](https://github.com/edkolev/tmuxline.vim) but it didn't render the colors correctly.
Furthermore, with `tmuxline.vim`, you can't control the widgets on right status bar, which is a key feature IMO.

A picture of my terminal with *@onedark_widgets* set to "*#{package_updates} #{free_mem}*".
These widgets are available in [tmux-status-variables](https://github.com/odedlaz/tmux-status-variables).
![tmux-onedark-theme Preview](preview-terminal.png)

## Modes

`@onedark_adaptive` picks how far the bar adapts (default `off`):

- **`off`** — the original One Dark palette; ignores system appearance.
- **`light`** — chrome follows the system: One Dark when dark, Atom One Light when light.
- **`full`** — `light`, plus the accent and semantic marks come from the terminal's own ANSI palette so those hues match the terminal theme. The chrome (bar bg, tab bg, body text) is unaffected — only the session/host pill = accent (`@onedark_accent`, default `colour2`), the activity mark/cap = `colour3`, and the bell mark/cap = `colour1`.

Override the automatic light/dark detection with `@onedark_appearance` (`light` | `dark`; default `auto`, which reads macOS `defaults read -g AppleInterfaceStyle` or the GNOME `color-scheme`). Only the palette values change between modes.

### Live light/dark switching

`light`/`full` resolve the appearance each time the theme runs. To repaint the instant the OS toggles (rather than on the next attach), have something re-run `tmux-onedark-theme.tmux` on the appearance-change event — for example a small resident watcher on macOS's `AppleInterfaceThemeChangedNotification`. A `client-attached` hook covers fresh attaches. The theme sets an explicit `PATH` (so `tmux` resolves under launchd) and refreshes clients at the end, so it re-applies cleanly from such a watcher.

### Activity and bell

A window's `#I`/`#W` separator turns yellow on activity and red on a bell, instead of the default reverse-video banner.

## Set options

**!** Set the following options in your `.tmux.conf`

### Widgets

Widgets can be controlled by setting `@onedark_widgets`, for example:

```
set -g @onedark_widgets "#(date +%s)"
```

Once set, these widgets will show on the right.

**default**: empty string.

### Time format

Time format can be controlled by setting `@onedark_time_format`, for example:

```
set -g @onedark_time_format "%I:%M %p"
```

`%I` - The hour as a decimal number using a 12-hour clock
`%M` - The minute as a decimal number
`%p` -  Either "AM" or "PM" according to the given time value.

**default**: `%R` - The time in 24-hour notation (%H:%M).

These modifiers were taken from the [strftime manpage](http://man7.org/linux/man-pages/man3/strftime.3.html).

### Date format

Date format can be controlled by setting `@onedark_date_format`, for example:

```
set -g @onedark_date_format "%D"
```

`%D` - Equivalent to %m/%d/%y (American format).
`%m` - The month as a decimal number.
`%d` - The day of the month as a decimal number
`%y` - The year as a decimal number without the century.

**default**: `%d/%m/%Y` - The date in non-American format.

These modifiers were taken from the [strftime manpage](http://man7.org/linux/man-pages/man3/strftime.3.html).

## Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add the plugin to the list of TPM plugins in `.tmux.conf`:

```
set -g @plugin 'lukewang1024/tmux-onedark-theme'
```

Hit `prefix + I` to fetch the plugin and source it.

## Manual Installation

Clone the repo:

```
$ git clone https://github.com/lukewang1024/tmux-onedark-theme /a/path/you/choose
```

Add this line to the bottom of `.tmux.conf`:

```
run-shell /a/path/you/choose/tmux-onedark-theme.tmux
```

Reload the TMUX environment (type this in a terminal):
```
$ tmux source-file ~/.tmux.conf
```

## Issues

### Symbols are missing

   The theme requires Powerline symbols to exist and be set on your system. Follow [these instructions](https://github.com/powerline/fonts) to install them, then update your terminal fonts to use them.

### Symbols are corrupted

   Patched Powerline fonts aren't picked up when `$LANG` isn't set to `en_US`.
   You can change the default locale settings at `/etc/default/locale`.

### Widgets not working

   Make sure that you put the `set -g @plugin 'lukewang1024/tmux-onedark-theme'` before other scripts that alter the status line, or they won't be able to pick up the plugin's changes.

### True Color

   tmux version <= 2.3 doesn't support true color in the status line.
   [Support has been added](https://github.com/tmux/tmux/issues/490) in later releases.

   Make sure TrueColor is enabled and working — follow [these instructions](https://sunaku.github.io/tmux-24bit-color.html#usage) to do so.

## License

[MIT](LICENSE)

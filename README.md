# theme.nvim

`theme.nvim` is a simple way to set a different theme derived from macOS system appearance (Sorry! Only macOS as of right now). You can also manually change the theme.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'mattrussell36/theme.nvim',
    opts = {
      themes = {
        dark = 'catppuccin-mocha',
        light = 'catppuccin-latte',
      },
      timer_interval = 3000,
      default_theme = 'dark'
    },
    dependencies = {
      { 'catppuccin/nvim', priority = 1000 },
    },
}
```

## Usage

- `:Theme <theme>` to change the theme.
- `:Theme stop_appearance_check` to stop automatically checking system appearance. This will be called when you manually change the theme.
- `:Theme start_appearance_check` to start automatically checking system appearance. This will be called when the plugin initializes.


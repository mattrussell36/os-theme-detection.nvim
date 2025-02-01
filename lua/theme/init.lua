--@alias Theme 'dark' | 'light'
--@alias Themes table<string, string>

--@type table<string, string>
local themes

--@type Theme
local default_theme

--@type number
local timer_id

--@type number
local timer_interval

-- Sets the theme using the `colorscheme` command. Theme must be provided in the `options.themes`
--@param theme string
--@return void
local function set_theme(theme)
  local t = themes[theme]

  if not t then
    vim.notify("Theme " .. theme .. " not found", vim.log.levels.ERROR)
    return
  end

  vim.cmd.colorscheme(t)
end

-- Gets the macos system appearance using io.popen
--@return Theme
local function get_system_appearance()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")

  if not handle then
    return default_theme
  end

  local result = handle:read("*a")
  handle:close()
  return result:match("Dark") and "dark" or "light"
end

-- Starts a time that gets the system appearance every `timer_interval` milliseconds.
--@return void
local function start_checking()
  timer_id = vim.fn.timer_start(timer_interval, function()
    local system_appearance = get_system_appearance()
    set_theme(system_appearance)
  end, { ["repeat"] = -1 })
end

-- Stops the timer that checks the system appearance.
--@return void
local function stop_checking()
  vim.fn.timer_stop(timer_id)
  timer_id = nil
end

local function init()
  if not (vim.uv.os_uname().sysname == "Darwin") then
    vim.notify("Sorry! This only works on macOS Darwin right now.", vim.log.levels.ERROR)
    return
  end

  local system_appearance = get_system_appearance()
  set_theme(system_appearance)
  start_checking()

  -- User command to manually change theme, this will stop the interval
  -- used to automatically set the theme when the system appearance changes.
  vim.api.nvim_create_user_command("Theme", function(opts)
    set_theme(opts.args)
    stop_checking()
  end, { nargs = 1 })
end

--@type class ThemeOptions
-- Table containing the desired theme for dark and light
--@field themes Themes
-- How often to check the system appearance in milliseconds
--@field timer_interval number?
-- The fallback theme if system apperance cannot be retrieved
--@fields default_theme Theme?

--@param options ThemeOptions
local function setup(options)
  options = options or {}

  if not options.themes then
    vim.notify("Themes table is required", vim.log.levels.ERROR)
    return
  end

  themes = options.themes
  timer_interval = options.timer_interval or 3000
  default_theme = options.default_theme or "dark"

  init()
end

return {
  setup = setup,
  start_appearance_check = start_checking,
  stop_appearance_check = stop_checking,
}

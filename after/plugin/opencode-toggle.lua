-- Restore toggle() for opencode.nick (removed in v0.11.0)
-- Uses snacks.terminal for reliable fullscreen/floating toggle

local opencode_cmd = "opencode --port"
local snacks_opts = {
  win = {
    position = "right",
    width = 0.35,
    height = 1.0,
    border = "rounded",
  },
}

local M = {}

-- Toggle the opencode terminal
M.toggle = function()
  require("snacks.terminal").toggle(opencode_cmd, snacks_opts)
end

-- Start the opencode terminal
M.start = function()
  require("snacks.terminal").open(opencode_cmd, snacks_opts)
end

-- Stop the opencode terminal
M.stop = function()
  local term = require("snacks.terminal").get(opencode_cmd, { create = false })
  if term then
    term:close()
  end
end

-- Ensure terminal is open, return true if already running
M.ensure_open = function()
  return require("snacks.terminal").get(opencode_cmd, { create = false }) ~= nil
end

-- Inject into require("opencode") module
local ok, opencode = pcall(require, "opencode")
if ok then
  opencode.toggle = M.toggle
  opencode.start = M.start
  opencode.stop = M.stop
  opencode.ensure_open = M.ensure_open
else
  vim.notify("Failed to patch opencode.nick: module not found", vim.log.levels.ERROR)
end
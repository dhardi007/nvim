local M = {}

M.patch_presence = function(dir)
  local function read(p)
    return vim.fn.readfile(p)
  end
  local function write(p, lines)
    vim.fn.writefile(lines, p)
  end
  local function has_mark(lines)
    for _, l in ipairs(lines) do
      if l:find("dizzi patch") then
        return true
      end
    end
    return false
  end

  -- 1) Strip any previously applied patch so lazy updates never fail
  -- on local changes, then reapply (idempotent).
  vim.fn.system({ "git", "-C", dir, "checkout", "--", "autoload/presence.vim", "lua/presence/init.lua" })

  -- 2) autoload/presence.vim: react to terminal job focus (ModeChanged -> t)
  local vim_f = dir .. "/autoload/presence.vim"
  local vim_lines = read(vim_f)
  if not has_mark(vim_lines) then
    local out = {}
    for _, l in ipairs(vim_lines) do
      out[#out + 1] = l
      if l:find("autocmd BufAdd %* lua package.loaded.presence:handle_buf_add%(%)") then
        out[#out + 1] = "            \" [dizzi patch] Terminal focus: clicking/focusing a term:// job"
        out[#out + 1] = "            \" enters mode 't', which fires no BufEnter. Auto-reapplied by build."
        out[#out + 1] = "            autocmd ModeChanged *:t,t:* lua package.loaded.presence:handle_buf_enter()"
      end
    end
    write(vim_f, out)
  end

  -- 3) lua/presence/init.lua: terminal_text default option
  local init_f = dir .. "/lua/presence/init.lua"
  local init_lines = read(init_f)
  if not has_mark(init_lines) then
    local out = {}
    for _, l in ipairs(init_lines) do
      if l:find('self:set_option%("reading_text", "Reading %%s"%)') then
        out[#out + 1] = l
        out[#out + 1] = '    self:set_option("terminal_text", "Working in terminal: %s") -- [dizzi patch] term:// buffers'
      else
        out[#out + 1] = l
      end
    end

    -- 4) lua/presence/init.lua: terminal buffer branch in get_status_text
    local out2 = {}
    for _, l in ipairs(out) do
      if l:find('if not filename or filename == "" then return nil end') then
        out2[#out2 + 1] = '    -- [dizzi patch] Terminal buffers (term://): show the job command instead'
        out2[#out2 + 1] = '    -- of "Reading <pid>:<cmd>". Auto-reapplied by the plugin build.'
        out2[#out2 + 1] = '    if vim.bo.buftype == "terminal" then'
        out2[#out2 + 1] = '        local term_title = vim.b.term_title or ""'
        out2[#out2 + 1] = '        if term_title == "" or term_title:find("^term://") then'
        out2[#out2 + 1] = '            term_title = filename or "Terminal"'
        out2[#out2 + 1] = '        end'
        out2[#out2 + 1] = '        term_title = term_title:gsub("^%d+:", "")'
        out2[#out2 + 1] = '        return self:format_status_text("terminal", term_title)'
        out2[#out2 + 1] = '    end'
      end
      out2[#out2 + 1] = l
    end
    write(init_f, out2)
  end
end

return M
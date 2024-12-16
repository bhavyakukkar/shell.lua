
Cmd = {
  meta = {
    -- Chain this command with another argument
    -- (called when command is followed by a space and a string [or table] literal)
    __call = function(self, arg)
      return Cmd.append(self, arg)
    end,

    -- Invoke this command
    -- (automatically called by repl)
    __tostring = function(self)
      local output = ''
      if self.before then
        output = output .. Cmd.exec(self.before)
        return output .. Cmd.exec(self)
      elseif self.pipe then
        output = output .. Cmd.exec(self, Cmd.exec(self.pipe))
        return output
      else
        return output .. Cmd.exec(self)
      end
    end,

    -- Comment-out this command
    -- (user can prefix with #)
    __len = function(self)
      return ''
    end,

    -- Pipe this command into that command
    __bor = function(self, other)
      other.pipe = self
      return other
    end,

    __unm = function(self)
      return self
    end,

    __sub = function(self, flag)
      return Cmd.append(self, '-' .. flag.exe)
    end,
  },

  display = function(self)
    local cmdstr = self.exe
    for _, arg in ipairs(self.args) do
      cmdstr = cmdstr .. ' ' .. arg
    end
    return cmdstr
  end,

  exec = function(self, stdin)
    -- TODO here
    if stdin then end
    local handle = io.popen(Cmd.display(self))
    local out = handle:read('*a')
    handle:close()
    return out
  end,

  append = function(self, arg)
    table.insert(self.args, arg)
    return self
  end,

  new = function(exe)
    local self = { exe = exe, args = {}, before = nil }
    setmetatable(self, Cmd.meta)
    return self
  end,
}

protected = { _PROMPT = true, _PROMPT2 = true, }
setmetatable( _G, {
  __index = function(_, exe)
    if not protected[exe] then
      local cmd = Cmd.new(exe)
      return cmd
    end
  end
})


Cmd = {
  meta = {
    __call = function(self, arg)
      return self:append(arg)
    end,

    __tostring = function(self)
      local handle = io.popen(self:display())
      local out = handle:read('*a')
      handle:close()
      return out
    end,
  },

  display = function(self)
    local args = ''
    for _, arg in ipairs(self.args) do
      args = args .. ' ' .. arg
    end
    return self.exe .. args
  end,

  append = function(self, arg)
    table.insert(self.args, arg)
    return self
  end,

  new = function(exe)
    local self = {
      exe = exe,
      args = {},

      append = Cmd.append,
      display = Cmd.display,
    }
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

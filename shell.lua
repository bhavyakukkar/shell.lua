#!/usr/bin/env lua -i

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
      Cmd.execute(self)
      return ''
    end,

    -- Execute this command and get it's output
    __len = function(self)
      return Cmd.execute(self, true)
    end,

    -- Pipe this command into that command
    __bor = function(self, other)
      if getmetatable(other) == Cmd.meta then
        self.exec = self.exec .. ' | ' .. other.exec
      else
        self.exec = self.exec .. ' | ' .. other
      end
      return self
    end,

    -- -flags
    __sub = function(self, flag)
      if getmetatable(flag) == Cmd.meta then
        return Cmd.append(self, '-' .. flag.exec)
      else
        return Cmd.append(self, '-' .. flag)
      end
    end,
  },

  new = function(exe)
    local self = { exec = exe }
    setmetatable(self, Cmd.meta)
    return self
  end,

  append = function(self, arg)
    if getmetatable(arg) == Cmd.meta then
      self.exec = self.exec .. ' ' .. arg.cmd
    else
      self.exec = self.exec .. ' ' .. arg
    end
    return self
  end,

  execute = function(self, capture)
    local handle = io.popen(self.exec, capture and 'r' or 'w')
    local output
    if handle and capture then
      output = capture and handle:read('*a') or ''
    end
    local _, _exit_kind, exit_code = io.close(handle)
    if capture then
      return output, exit_code
    else
      return exit_code
    end
  end,
}

protected = { _PROMPT = true, _PROMPT2 = true, }
setmetatable( _G, {
  __index = function(_, ident)
    if not protected[ident] then
      local cmd = Cmd.new(ident)
      return cmd
    end
  end
})

Prompt = {
  meta = {
    __tostring = function(self)
      return self:prompt()
    end,
  },
}

setmetatable(Prompt, Prompt.meta)

local config = loadfile(os.getenv("HOME") .. "/.shell.lua")
if config then
  config()
end
 

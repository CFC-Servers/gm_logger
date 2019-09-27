local insert
insert = table.insert
local CFCLogger
do
  local _class_0
  local _base_0 = {
    addCallbackFor = function(self, severity, callback)
      return insert(self.callbacks[severity], callback)
    end,
    runCallbacksFor = function(self, severity, message)
      local _accum_0 = { }
      local _len_0 = 1
      for _, callback in pairs(self.callbacks[severity]) do
        _accum_0[_len_0] = callback(message)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    on = function(self, severity)
      local scope = self
      local addCallback
      addCallback = function(self, callback)
        return scope.addCallbackFor(scope, severity, callback)
      end
      return {
        call = addCallback
      }
    end,
    _log = function(self, message, severity)
      if self.__class.severities[severity] >= self.__class.severities[self.logLevel] then
        print("[" .. tostring(self.projectName) .. "] [" .. tostring(severity) .. "] " .. tostring(message))
      end
      return self:runCallbacksFor(severity, message)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, projectName, logLevel)
      self.projectName = projectName
      self.logLevel = logLevel or "info"
      do
        local _tbl_0 = { }
        for severity, _ in pairs(self.__class.severities) do
          _tbl_0[severity] = { }
        end
        self.callbacks = _tbl_0
      end
      for severity, _ in pairs(self.__class.severities) do
        self[severity] = function(self, message)
          return self:_log(message, severity)
        end
      end
    end,
    __base = _base_0,
    __name = "CFCLogger"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.severities = {
    ["trace"] = 0,
    ["debug"] = 1,
    ["info"] = 2,
    ["warn"] = 3,
    ["error"] = 4,
    ["fatal"] = 5
  }
  CFCLogger = _class_0
end
local myLogger = CFCLogger("MyLogger")
myLogger:addCallbackFor("fatal", function(message)
  return print("Alerting webhooker of fatal message: " .. tostring(message))
end)
local newLogger = CFCLogger("CFC_PvP")
newLogger:on("error"):call(function(message)
  return print("This is an Error callback for: " .. tostring(message))
end)
myLogger:trace("This is a trace message!")
myLogger:debug("This is a debug message!")
myLogger:info("This is an info message!")
myLogger:warn("This is an warn message!")
myLogger:error("This is an error message!")
myLogger:fatal("This is an fatal message!")
newLogger:addCallbackFor("fatal", function(message)
  return print("CALLBACK FOR: " .. tostring(message))
end)
newLogger:debug("Getting PvP Status!")
newLogger:error("HERE I GO THROWING AGAIN")
return newLogger:fatal("FATAL ERR")

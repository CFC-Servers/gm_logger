require("moonscript")
local insert
insert = table.insert
do
  local _class_0
  local _base_0 = {
    addCallbackFor = function(self, severity, callback)
      return insert(self.callbacks[severity], callback)
    end,
    runCallbacksFor = function(self, severity, message)
      for _, callback in pairs(self.callbacks[severity]) do
        callback(message)
      end
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
local my_logger = CFCLogger("CFC Logger")
return my_logger:info("Loaded!")

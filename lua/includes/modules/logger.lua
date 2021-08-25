local insert, concat, ToString
do
  local _obj_0 = table
  insert, concat, ToString = _obj_0.insert, _obj_0.concat, _obj_0.ToString
end
local istable, pairs, print, tostring
do
  local _obj_0 = _G
  istable, pairs, print, tostring = _obj_0.istable, _obj_0.pairs, _obj_0.print, _obj_0.tostring
end
local LOG_LEVEL_OVERRIDE = CreateConVar("logger_forced_level", "")
local forcedLogLevel
forcedLogLevel = function()
  local level = LOG_LEVEL_OVERRIDE:GetString()
  if level == "" then
    return nil
  end
  return level
end
do
  local _class_0
  local _base_0 = {
    scope = function(self, scope, logLevel)
      if logLevel == nil then
        logLevel = self.logLevel
      end
      return Logger(scope, logLevel, self)
    end,
    addCallbackFor = function(self, severity, callback)
      return insert(self.callbacks[severity], callback)
    end,
    runCallbacksFor = function(self, severity, message)
      local _list_0 = self.callbacks[severity]
      for _index_0 = 1, #_list_0 do
        local callback = _list_0[_index_0]
        callback(message)
      end
      if not (self.parent) then
        return 
      end
      if not (self.runParentCallbacks) then
        return 
      end
      return self.parent:runCallbacksFor(severity, message)
    end,
    on = function(self, severity)
      local scope = self
      local addCallback
      addCallback = function(self, callback)
        return scope:addCallbackFor(severity, callback)
      end
      return {
        call = addCallback
      }
    end,
    _formatParams = function(self, ...)
      local values = {
        ...
      }
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #values do
          local v = values[_index_0]
          _accum_0[_len_0] = istable(v) and ToString(v) or tostring(v)
          _len_0 = _len_0 + 1
        end
        values = _accum_0
      end
      return concat(values, " ")
    end,
    _log = function(self, severity, ...)
      if self.__class.severities[severity] < self.__class.severities[self.logLevel] then
        return 
      end
      local messageParams = self:_formatParams(...)
      local message = tostring(self.prefix) .. "[" .. tostring(severity) .. "] " .. tostring(messageParams)
      print(message)
      return self:runCallbacksFor(severity, message)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, logLevel, parent)
      self.name, self.parent = name, parent
      self.prefix = self.parent and self.parent.prefix or ""
      self.prefix = self.prefix .. "[" .. tostring(self.name) .. "] "
      self.logLevel = forcedLogLevel() or logLevel or "info"
      do
        local _tbl_0 = { }
        for severity in pairs(self.__class.severities) do
          _tbl_0[severity] = { }
        end
        self.callbacks = _tbl_0
      end
      for severity in pairs(self.__class.severities) do
        self[severity] = function(self, ...)
          return self:_log(severity, ...)
        end
      end
    end,
    __base = _base_0,
    __name = "Logger"
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
    trace = 0,
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
    fatal = 5
  }
  Logger = _class_0
end
return Logger("CFC Logger"):info("Loaded!")

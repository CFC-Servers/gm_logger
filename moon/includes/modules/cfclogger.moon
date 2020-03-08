AddCSLuaFile!

import insert from table

FORCED_LOG_LEVEL = (
    ->
        contents = file.Read "cfc/logger/forced_log_level.txt", "DATA"
        contents and string.gsub(contents, "%s", "") or nil
)!

export CFCLogger
class CFCLogger
    @@severities = {
        "trace": 0,
        "debug": 1,
        "info": 2,
        "warn": 3,
        "error": 4,
        "fatal": 5
    }

    new: (projectName, logLevel) =>
        @projectName = projectName
        @logLevel = FORCED_LOG_LEVEL or logLevel or "info"
        @callbacks = { severity,{} for severity,_ in pairs @@severities }

        for severity,_ in pairs @@severities
            @[severity] = (message) =>
                @_log(message, severity)

    addCallbackFor: (severity, callback) =>
        insert @callbacks[severity], callback

    runCallbacksFor: (severity, message) =>
        callback(message) for _,callback in pairs @callbacks[severity]

    on: (severity) =>
        scope = self

        addCallback = (callback) => scope.addCallbackFor(scope, severity, callback)

        { call: addCallback }

    _log: (message, severity) =>
        if @@severities[severity] >= @@severities[@logLevel]
            print "[#{@projectName}] [#{severity}] #{message}"

        @runCallbacksFor(severity, message)

-- Development tests
my_logger = CFCLogger("CFC Logger")

my_logger\info "Loaded!"

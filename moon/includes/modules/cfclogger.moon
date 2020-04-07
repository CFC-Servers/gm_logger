import Read from file
import gsub from string
import insert, concat, ToString from table

LOG_LEVEL_OVERRIDE = (
    ->
        contents = Read "cfc/logger/forced_log_level.txt", "DATA"
        contents and gsub(contents, "%s", "") or nil
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
        @logLevel = LOG_LEVEL_OVERRIDE or logLevel or "info"
        @callbacks = { severity,{} for severity in pairs @@severities }

        for severity in pairs @@severities
            @[severity] = (...) =>
                @_log(severity, ...)

    addCallbackFor: (severity, callback) =>
        insert @callbacks[severity], callback

    runCallbacksFor: (severity, message) =>
        callback message for callback in *@callbacks[severity]

    on: (severity) =>
        scope = self

        addCallback = (callback) => scope.addCallbackFor(scope, severity, callback)

        { call: addCallback }

    formatParams: (...) =>
        values = {...}

        -- Ensure all values are strings
        values = [istable(v) and ToString(v) or tostring(v) for v in *values]

        concat values, " "

    _log: (severity, ...) =>
        return if @@severities[severity] < @@severities[@logLevel]

        message = @formatParams ...
        print "[#{@projectName}] [#{severity}] #{message}"

        @runCallbacksFor(severity, message)

cfcLogger = CFCLogger "CFC Logger"
cfcLogger\info "Loaded!"

import insert, concat, ToString from table
import istable, pairs, print, tostring from _G

LOG_LEVEL_OVERRIDE = CreateConVar "cfc_logger_forced_level", ""
forcedLogLevel = ->
    level = LOG_LEVEL_OVERRIDE\GetString!

    return nil if level == ""
    return level

export class CFCLogger
    @@severities =
        trace: 0
        debug: 1
        info: 2
        warn: 3
        error: 4
        fatal: 5

    new: (@name, logLevel, @parent) =>
        @prefix = @parent and @parent.prefix or ""
        @prefix ..= "[#{@name}] "

        @logLevel = forcedLogLevel! or logLevel or "info"
        @callbacks = { severity,{} for severity in pairs @@severities }

        for severity in pairs @@severities
            @[severity] = (...) =>
                @_log(severity, ...)

    scope: (scope, logLevel=@logLevel) =>
        CFCLogger scope, logLevel, self

    addCallbackFor: (severity, callback) =>
        insert @callbacks[severity], callback

    runCallbacksFor: (severity, message) =>
        callback message for callback in *@callbacks[severity]

        return unless @parent
        return unless @runParentCallbacks

        @parent\runCallbacksFor severity, message

    on: (severity) =>
        addCallback = (callback) -> @addCallbackFor(scope, severity, callback)

        { call: addCallback }

    _formatParams: (...) =>
        values = {...}

        -- Ensure all values are strings
        values = [istable(v) and ToString(v) or tostring(v) for v in *values]

        concat values, " "

    _log: (severity, ...) =>
        return if @@severities[severity] < @@severities[@logLevel]

        messageParams = @_formatParams ...
        message = "#{@prefix}[#{severity}] #{messageParams}"

        print message

        @runCallbacksFor severity, message

CFCLogger("CFC Logger")\info "Loaded!"

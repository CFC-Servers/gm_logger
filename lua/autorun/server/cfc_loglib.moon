require "moonscript"

import insert from table

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
        @logLevel = logLevel or "info"
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
myLogger = CFCLogger("MyLogger")
myLogger\addCallbackFor("fatal", (message) -> print "Alerting webhooker of fatal message: #{message}")

newLogger = CFCLogger("CFC_PvP")
newLogger\on("error")\call((message) -> print "This is an Error callback for: #{message}")

myLogger\trace("This is a trace message!")
myLogger\debug("This is a debug message!")
myLogger\info("This is an info message!")
myLogger\warn("This is an warn message!")
myLogger\error("This is an error message!")
myLogger\fatal("This is an fatal message!")

newLogger\addCallbackFor("fatal", (message) -> print "CALLBACK FOR: #{message}")

newLogger\debug("Getting PvP Status!")
newLogger\error("HERE I GO THROWING AGAIN")
newLogger\fatal("FATAL ERR")

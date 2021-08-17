# CFC's Logging Library

# Glossary
 - [Installation](#installation)
 - [Usage](#usage)
 - [Logging Levels](#logging-levels)
 - [Callbacks](#callbacks)
 - [Scopes](#scopes)
 - [Global Override](#global-override)


## Installation
Simply download a copy of the zip, or clone the repository straight into your addons folder! 

Pre-compiled versions are available in **[Releases](https://github.com/CFC-Servers/cfc_logger/releases/)**

The [`lua` branch](https://github.com/CFC-Servers/cfc_logger/tree/lua) is a lua-only branch containing the compiled code from the most recent release. One can use this to easily keep `cfc_logger` up to date.
```sh
git clone --single-branch --branch lua git@github.com:CFC-Servers/cfc_logger.git
```

## Usage
CFCLogger lets you create and configure your own logging object to be used in your project.

Barebones usage example:
```lua
require( "cfclogger" )

local logger = CFCLogger( "MyProjectName" )

logger:trace( "This is an trace message!" )
logger:debug( "This is an debug message!" )
logger:info( "This is an info message!" )
logger:warn( "This is an warn message!" )
logger:error( "This is an error message!" )
logger:fatal( "This is an fatal message!" )
```

Which produces this output:
```
[MyProjectName] [info] This is an info message!
[MyProjectName] [warn] This is an warn message!
[MyProjectName] [error] This is an error message!
[MyProjectName] [fatal] This is an fatal message!
```

## Logging Levels
When a logger is created, one may pass an optional second parameter which defines the current log level of the app.
By default it's set to `"info"` which means everything but `debug` and `trace` messages are printed. (`trace < debug < info < warn < error < fatal`)

Any message sent with a lower log-level than the one defined in the logger object will not be printed.

As an example, if you set the default log level to `"error"`, then only `"error"` and `"fatal"` messages are printed.
```lua
require( "cfclogger" )

local logger = CFCLogger( "MyProjectName", "error" )

logger:trace( "This is an trace message!" )
logger:debug( "This is an debug message!" )
logger:info( "This is an info message!" )
logger:warn( "This is an warn message!" )
logger:error( "This is an error message!" )
logger:fatal( "This is an fatal message!" )
```

Output:
```
[MyProjectName] [error] This is an error message!
[MyProjectName] [fatal] This is an fatal message!
```

Log levels can be changed after instantiation.

For example,

```lua
require( "cfclogger" )
local logger = CFCLogger( "MyProjectName", "error" )

print( logger.logLevel )

logger.logLevel = "info"

print( logger.logLevel )
```
Would output:
```
error
info
```

## Callbacks
The logger object allows you to add callbacks to any log-level.
If a message comes through with the matching log level, the callback is called.

The callback is provided with one parameter; the contents of the message to be printed (before adding the prefixes like `"[MyProject]"`).

For example, maybe you want to forward all `fatal` messages to Discord.

The syntax for adding callbacks is as follows:
```lua
MyLoggingInstance:on( logLevel ):call( myCallback )
```

In an example:
```lua
require( "cfclogger" )

local function forwardFatalToDiscord( message )
    -- send the message to discord
    print( "Sending fatal message to discord! ( " .. message .. ")" )
end

local logger = CFCLogger( "MyProjectName" )
logger:on( "fatal" ):call( forwardFatalToDiscord )

logger:fatal( "Major oof!" )
```

Output:
```
[MyProjectName] [fatal] Major oof!
Sending fatal message to discord! ( Major oof!)
```

Please note that callbacks will only run for levels >= your currently selected log level.

This means that if your log level is set to `"error"`, but you add a callback to `"warn"`, all `"warn"` messages would not be printed in the console _and_ the callbacks wouldn't run.

As an example:
```lua
require( "cfclogger" )

local logger = CFCLogger( "MyProject", "fatal" )
logger:on( "warn" ):call(function(message) print("I'm a 'warn' callback!") end)

logger:warn("This is a test!")
```
Would output nothing.

## Scopes

If you have a project consisting of many modules, you can easily "extend" a Logger instance with Scopes, helping you discern where your log line came from.

e.g.
```lua
local MyProject = {}
MyProject.Logger = CFCLogger( "MyProject" )

MyProject.Storage = {}
MyProject.Storage.Logger = MyProject.Logger:scope( "Storage" )

MyProject.Logger:info( "Info from MyProject!" )
MyProject.Storage.Logger:info( "Info from Storage!" )
```

would print:

```
[MyProject] [info] Info from MyProject!
[MyProject] [Storage] [info] Info from Storage!
```


You can optionally inherit callbacks from a scoped logger's parent:
```lua
MyProject.Storage.Logger.runParentCallbacks = true
```
The Storage Logger would then inherit all callbacks set on `MyProject.Logger`

## Global Override
The log level for every newly-created Logger can be overridden by setting the `cfc_logger_forced_level` convar to a log level of your choice.


e.g. `cfc_logger_forced_level "debug"`

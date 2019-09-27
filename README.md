# CFC's Logging Library (BETA)



## Installation
Simply download a copy of the zip, or clone the repository straight into your addons folder! (When we finalize the API, we won't release breaking changes to master)


## Usage
CFCLogger lets you create and configure your own logging object to be used in your project.

## Logging Levels
When a logger is created, one may pass an optional second parameter which defines the current log level of the app.
By default it's set to `"info"` which means everything but `debug` and `trace` messages are printed. (`trace < debug < info < warn < error < fatal`)

Any message sent with a lower log-level than the one defined in the logger object will not be printed.

As an example, if you set the default log level to `"error"`, then only `"error"` and `"fatal"` messages are printed.
```lua
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

## Callbacks
The logger object allows you to add callbacks to any log-level.
If a message comes through with the matching log level, the callback is called.
The callback is provided with one parameter, the contents of the message to be printed ("Before adding the prefixes like [MyProject]").

For example, maybe you want to forward all `fatal` messages to Discord.

The syntax for adding callbacks is as follows:
```lua
MyLoggingInstance:on( logLevel ):call( myCallback )
```

In an example:
```lua
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

**Please note that the webhooks will run _regardless of the default log level setting_**.

This means that if your log level is set to `"error"`, but you add a callback to `"warn"`, all `"warn"` messages would not be printed in the console, but the attached callback _would_ fire.


## Example Usage

Barebones usage:
```lua
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

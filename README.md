Knit is a lightweight game framework. This version is an experimental version with parallelization support. The original framework can be found at [sleitnick/knit][knit].

# Usage
This is is a fork of [sleitnick/knit][knit]. All the standard Knit documentation is avalible at [sleitnick.github.io/Knit][knitdocs]. Only APIs that do not exist in standard Knit is documented here.
## Managers
Similarly to [services] and [controllers], this fork implements a new concept, managers. A manager is like a [service][services] or [controller][controllers], but they run on a separate actor.

Current manager limitations:
- No direct client <-> (nor ->) manager communication
- Managers do not fully respect the ``KnitInit`` & ``KnitStart`` lifecycle
- Methods are first "connected" in serial (rather than ``:ConnectParallel``) which requires the user to call ``task.synchronize()``. This also results in more context switches than needed.

### Lifecycle
(Registration & creation are used interchangeably)

Managers will not be registered before ``KnitInit``, but they may register before or after ``KnitStart``. A manager is ready to access [services] and [controllers] as soon as a manager is registered.

``KnitManagerCollection`` will not be parented to ``ServerScriptService`` (or ``ReplicatedStorage`` on clients) until it is ready, ``WaitForChild`` will yield until the module has been parented.

### Example
```lua
local ServerScriptService = game:GetService("ServerScriptService")

local ManagerCollection = require(ServerScriptService:WaitForChild("KnitManagerCollection"))

local ExampleManager = ManagerCollection.CreateManager({
	Name = "ExampleManager",
})

function ExampleManager:Compute(data)
	task.desynchronize()

	local result
	for key, value in data do
		--proccess
	end

	return result
end

local ExampleService = ManagerCollection.GetService("ExampleService")
ExampleService:Hello("world")
```

### Parallelization & answers
Note: whenever a function cannot be run in a desynchronized context, the ``ManagerCollection`` will automatically call ``task.synchronize()``. This is intentional. If you think this is an undesired behaviour, please open an issue.

If you ran the following code in a manager, the method would be called, but all return values would be discarded. The entirety of this code block can be run in a desynchronized context.
```lua
local ExampleService = ManagerCollection.GetService("ExampleService")
ExampleService:Hello("world")
```
If you want to get the return values, you must access the method via the ``Answer`` subtable, this tells the ``ManagerCollection`` that you want the return values. It is important that you are aware that this will yield until due to the nature of ``BindableFunctions`` that are used under the hood when calling via the ``Answer`` subtable.
```lua
local ExampleService = ManagerCollection.GetService("ExampleService")
local receivedData = ExampleService.Answer:Hello("world")
```
Make sure you only use the ``Answer`` subtable when you really need to.

# API
## ManagerCollection
The ``ManagerCollection`` should only be accessed from ``Managers``.

Access the ``ManagerCollection`` on the server via:
```lua
local ServerScriptService = game:GetService("ServerScriptService")
local ManagerCollection = require(ServerScriptService:WaitForChild("KnitManagerCollection"))
```
On the client:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ManagerCollection = require(ReplicatedStorage:WaitForChild("KnitManagerCollection"))
```

### ManagerCollection.GetService(serviceName: string)
Example:
```lua
local ExampleService = ManagerCollection.GetService("ExampleService")
local receivedData = ExampleService.Answer:Hello("world")
```
### ManagerCollection.GetController(controllerName: string)
Only avalible on clients.
Example:
```lua
local ExampleController = ManagerCollection.GetController("ExampleController")
local receivedData = ExampleController.Answer:Hello("world")
```
### ManagerCollection.GetManager(managerName: string)
Used to access other ``Managers`` from a manager, does not travel through client <-> server.
Example:
```lua
local OtherManager = ManagerCollection.GetManager("OtherManager")
OtherManager:Hello("world")
```
### ManagerCollection.CreateManager(manager: Manager)
Runs in a synchronized context.

Used to create/register a manager. Works similarly to [services] and [controllers].
Example:
```lua
local ExampleManager = ManagerCollection.CreateManager({
	Name = "ExampleManager",
})
```

[knit]: https://github.com/Sleitnick/Knit
[knitdocs]: https://sleitnick.github.io/Knit/
[services]: https://sleitnick.github.io/Knit/docs/services
[controllers]: https://sleitnick.github.io/Knit/docs/controllers
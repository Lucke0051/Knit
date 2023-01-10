local ServerScriptService = game:GetService("ServerScriptService")

local ManagerCollection = require(ServerScriptService:WaitForChild("KnitManagerCollection") :: ModuleScript)

local ExampleManager = ManagerCollection.CreateManager({
	Name = "ExampleManager",
	Client = {},
})

task.desynchronize()

function ExampleManager:ExampleMethod(test: string)
	print(test)
end

function ExampleManager:Print(text: string)
	print(text)
end

function ExampleManager:GetText()
	task.desynchronize()
	return "the best text"
end

local ExampleService = ManagerCollection.GetService("ExampleService")
ExampleService:SetText("no world")

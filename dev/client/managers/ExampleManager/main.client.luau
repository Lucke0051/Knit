local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ManagerCollection = require(ReplicatedStorage:WaitForChild("KnitManagerCollection") :: ModuleScript)

local ExampleManager = ManagerCollection.CreateManager({
	Name = "ExampleManager",
	Client = {},
})

task.desynchronize()

local ExampleService = ManagerCollection.GetService("ExampleService")
local ExampleController = ManagerCollection.GetController("ExampleController")
print(ExampleService.Answer:GetText())
ExampleController:Set("wow")
print(ExampleService.Answer:GetText())

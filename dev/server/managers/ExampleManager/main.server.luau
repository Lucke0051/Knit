local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ManagerCollection = require(ReplicatedStorage.Packages.Knit).ManagerCollection

local ExampleManager = ManagerCollection.CreateManager({
	Name = "ExampleManager",
	Client = {},
})

function ExampleManager:KnitStart()
	local ExampleService = ManagerCollection.GetService("ExampleService")
end
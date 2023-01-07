local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExampleController = Knit.CreateController({ Name = "ExampleController" })

function ExampleController:KnitInit() end

function ExampleController:KnitStart()
	local ExampleService = Knit.GetService("ExampleService")
	print(ExampleService:GetTest())
end

return ExampleController

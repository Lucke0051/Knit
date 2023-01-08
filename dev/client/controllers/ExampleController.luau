local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExampleController = Knit.CreateController({ Name = "ExampleController" })

function ExampleController:Set(text)
	self.ExampleService:SetText(text)
end

function ExampleController:KnitInit() end

function ExampleController:KnitStart()
	self.ExampleService = Knit.GetService("ExampleService")
	print(self.ExampleService:GetText():await())
	print(self.ExampleService:GetManagersText():await())
end

return ExampleController

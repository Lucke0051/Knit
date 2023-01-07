local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExampleService = Knit.CreateService({
	Name = "ExampleService",
	Client = {},
})

function ExampleService:SetText(text: string)
	self.Text = text
	print("Set text to:", text)
end

function ExampleService.Client:GetTest()
	return self.Server.Text
end

function ExampleService:KnitInit()
	self.Text = "hello"
end

function ExampleService:KnitStart() end

return ExampleService

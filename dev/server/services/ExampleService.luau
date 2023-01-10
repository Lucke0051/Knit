local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExampleService = Knit.CreateService({
	Name = "ExampleService",
})

function ExampleService:SetText(text: string)
	self.Text = text
	print("Set text to:", text)
end

function ExampleService.Client:SetText(_, text: string)
	self.Server.Text = text
	print("Set text from client to:", text)
end

function ExampleService:GetText()
	return self.Text
end

function ExampleService.Client:GetManagersText()
	return self.Server.ExampleManager.Answer:GetText()
end

function ExampleService.Client:GetText()
	return self.Server.Text
end

function ExampleService:KnitInit()
	self.Text = "hello"
end

function ExampleService:KnitStart()
	self.ExampleManager = Knit.GetManager("ExampleManager")
	self.ExampleManager.Parallel:Print("in parallel: " .. self.Text)
end

return ExampleService

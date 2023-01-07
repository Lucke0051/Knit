type Manager = {
	Name: string,
	KnitStart: () -> (),
}

local ManagerCollection = {
	Managers = {},
}

local function registerManager(manager: Manager)
	assert(
		ManagerCollection.Managers[manager.Name] == nil,
		"Manager with name '" .. manager.Name .. "' already exists!"
	)

	ManagerCollection.Managers[manager.Name] = manager
end

function ManagerCollection.CreateManager(manager: Manager)
	script:WaitForChild("RegistryCommunication"):Fire(manager)
end

function ManagerCollection._setup()
	local registryCommunication: BindableEvent = Instance.new("BindableEvent")
	registryCommunication.Name = "RegistryCommunication"
	registryCommunication.Event:Connect(registerManager)
	registryCommunication.Parent = script
end

function ManagerCollection._start()
	--TODO
end

return ManagerCollection

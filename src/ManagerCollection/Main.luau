--!native

local RunService = game:GetService("RunService")

type Manager = {
	Name: string,
	KnitStart: ((Manager) -> ())?,
}

local managers: { [string]: Manager | true } = {}

local ManagerCollection = {}

local isClient = RunService:IsClient()
local storageService = if isClient then game:GetService("ReplicatedStorage") else game:GetService("ServerScriptService")

function ManagerCollection.GetComm(commKind: string, commName: string)
	assert(commKind == "S" or commKind == "C", "Invalid comm kind: " .. tostring(commKind))
	assert(commKind ~= "C" or isClient, "Cannot access controllers on the server!")

	local commMethod: BindableEvent = script.CommMethod
	local commAnswerMethod: BindableFunction = script.CommAnswerMethod

	local proxyTable = {
		Answer = {},
	}

	setmetatable(proxyTable, {
		__index = function(_, key: any)
			return function(selfPerhaps, ...)
				if selfPerhaps == proxyTable then
					commMethod:Fire(commKind, commName, key, true, ...)
				else
					commMethod:Fire(commKind, commName, key, false, ...)
				end
			end
		end,
		__newindex = function()
			error("Cannot set values on service proxies!")
		end,
	})

	setmetatable(proxyTable.Answer, {
		__index = function(_, key: any)
			return function(selfPerhaps, ...)
				task.synchronize()
				if selfPerhaps == proxyTable.Answer then
					return commAnswerMethod:Invoke(commKind, commName, key, true, ...)
				else
					return commAnswerMethod:Invoke(commKind, commName, key, false, ...)
				end
			end
		end,
		__newindex = function()
			error("Cannot set values on service answer proxies!")
		end,
	})

	return proxyTable
end

ManagerCollection.GetService = function(...)
	return ManagerCollection.GetComm("S", ...)
end

if isClient then
	ManagerCollection.GetController = function(...)
		return ManagerCollection.GetComm("C", ...)
	end
end

function ManagerCollection.CreateManager(newManager: Manager): Manager
	task.synchronize()

	managers[newManager.Name] = newManager

	local commEvent: BindableEvent = Instance.new("BindableEvent")
	commEvent.Name = "CommEvent"

	local commParallelEvent: BindableEvent = Instance.new("BindableEvent")
	commParallelEvent.Name = "CommParallelEvent"

	local commFunction: BindableFunction = Instance.new("BindableFunction")
	commFunction.Name = "CommFunction"

	commEvent.Event:Connect(function(key: any, prefixSelf: boolean, ...)
		if prefixSelf then
			newManager[key](newManager, ...)
		else
			newManager[key](...)
		end
	end)

	commParallelEvent.Event:ConnectParallel(function(key: any, prefixSelf: boolean, ...)
		if prefixSelf then
			newManager[key](newManager, ...)
		else
			newManager[key](...)
		end
	end)

	commFunction.OnInvoke = function(key: any, prefixSelf: boolean, ...)
		if prefixSelf then
			return newManager[key](newManager, ...)
		else
			return newManager[key](...)
		end
	end

	local commFolder: Folder = Instance.new("Folder")
	commFolder.Name = newManager.Name

	commEvent.Parent = commFolder
	commParallelEvent.Parent = commFolder
	commFunction.Parent = commFolder
	commFolder.Parent = script.ManagerComms

	script.RegistryRegistration:Fire(newManager.Name)

	return newManager
end

function ManagerCollection.GetManager(managerName: string)
	assert(type(managerName) == "string", "ManagerName must be a string; got " .. type(managerName))

	local managerComms: Folder = script.ManagerComms:WaitForChild(managerName)
	local commEvent: BindableEvent = (managerComms :: any).CommEvent
	local commParallelEvent: BindableEvent = (managerComms :: any).CommParallelEvent
	local commFunction: BindableFunction = (managerComms :: any).CommFunction

	local proxyTable = {
		Answer = {},
		Parallel = {},
	}

	setmetatable(proxyTable, {
		__index = function(_, key: any)
			return function(selfPerhaps, ...)
				if selfPerhaps == proxyTable then
					commEvent:Fire(key, true, ...)
				else
					commEvent:Fire(key, false, ...)
				end
			end
		end,
		__newindex = function()
			error("Cannot set values on service proxies!")
		end,
	})

	setmetatable(proxyTable.Answer, {
		__index = function(_, key: any)
			return function(selfPerhaps, ...)
				task.synchronize()
				if selfPerhaps == proxyTable.Answer then
					return commFunction:Invoke(key, true, ...)
				else
					return commFunction:Invoke(key, false, ...)
				end
			end
		end,
		__newindex = function()
			error("Cannot set values on service answer proxies!")
		end,
	})

	setmetatable(proxyTable.Parallel, {
		__index = function(_, key: any)
			return function(selfPerhaps, ...)
				if selfPerhaps == proxyTable.Parallel then
					commParallelEvent:Fire(key, true, ...)
				else
					commParallelEvent:Fire(key, false, ...)
				end
			end
		end,
		__newindex = function()
			error("Cannot set values on service parallel proxies!")
		end,
	})

	return proxyTable
end

function ManagerCollection._setup(knit, servicePromises: boolean)
	script.Name = "KnitManagerCollection"

	local registryRegistration: BindableEvent = Instance.new("BindableEvent")
	registryRegistration.Name = "RegistryRegistration"
	registryRegistration.Event:Connect(function(managerName: string)
		assert(managers[managerName] == nil, "Manager with name '" .. managerName .. "' already exists!")

		managers[managerName] = true
	end)

	local commMethod: BindableEvent = Instance.new("BindableEvent")
	commMethod.Name = "CommMethod"
	commMethod.Event:Connect(function(commKind: string, commName: string, key: any, prefixSelf: boolean, ...)
		local comm = if commKind == "S" then knit.GetService(commName) else knit.GetController(commName)
		if prefixSelf then
			comm[key](comm, ...)
		else
			comm[key](...)
		end
	end)

	local commAnswerMethod: BindableFunction = Instance.new("BindableFunction")
	commAnswerMethod.Name = "CommAnswerMethod"
	commAnswerMethod.OnInvoke = function(commKind: string, commName: string, key: any, prefixSelf: boolean, ...)
		if commKind == "S" then
			local comm = knit.GetService(commName)
			if isClient and servicePromises then
				return select(1, (if prefixSelf then comm[key](comm, ...) else comm[key](...)):await())
			else
				return if prefixSelf then comm[key](comm, ...) else comm[key](...)
			end
		else
			local comm = knit.GetController(commName)
			return if prefixSelf then comm[key](comm, ...) else comm[key](...)
		end
	end

	local managerCommsFolder: Folder = Instance.new("Folder")
	managerCommsFolder.Name = "ManagerComms"

	managerCommsFolder.Parent = script
	commMethod.Parent = script
	commAnswerMethod.Parent = script
	registryRegistration.Parent = script

	--selene: allow(incorrect_standard_library_use)
	script.Parent = storageService
end

return ManagerCollection

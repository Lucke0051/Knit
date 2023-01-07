if game:GetService("RunService"):IsServer() then
	return require(script.KnitServer)
else
	local KnitServer = script:FindFirstChild("KnitServer")
	if KnitServer then
		KnitServer:Destroy()
	end

	local ManagerCollection = script:FindFirstChild("ManagerCollection")
	if ManagerCollection then
		ManagerCollection:Destroy()
	end

	return require(script.KnitClient)
end

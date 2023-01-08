if game:GetService("RunService"):IsServer() then
	return require(script.Main:Clone())
else
	return require(script.Main)
end

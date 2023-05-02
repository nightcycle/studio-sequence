local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))

return function(coreGui: ScreenGui)
	local maid = Maid.new()

	task.spawn(function()
		local _Module = require(script.Parent)
		_Module.init(maid)
	end)

	return function()
		maid:Destroy()
	end
end

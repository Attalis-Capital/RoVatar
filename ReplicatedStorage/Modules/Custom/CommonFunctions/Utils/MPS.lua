-- @ScriptType: ModuleScript
return {
	GetProductInfo = function(productId:number, infoTyp:Enum.InfoType?)

		local s, r = pcall(function()
			return game:GetService('MarketplaceService'):GetProductInfo(tonumber(productId), infoTyp)
		end)

		if(s) then
			return r
		end

		return nil 
	end,
}

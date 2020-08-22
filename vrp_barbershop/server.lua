local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRPbs = {}
Tunnel.bindInterface("vrp_barbershop",vRPbs)
Proxy.addInterface("vrp_barbershop",vRPbs)
BSclient = Tunnel.getInterface("vrp_barbershop")

local cfg = module("vrp_barbershop","cfg/barbershop")
local barbershops = cfg.barbershops

function vRPbs.openBarbershop(source,parts)
	local user_id = vRP.getUserId(source)
	if user_id then
		local old_custom = BSclient.getOverlay(source)
		local menudata = { name = "Salao de Beleza" }
		local drawables = {}
		local textures = {}
		local ontexture = function(player,choice)
			local texture = textures[choice]
			texture[1] = texture[1]+1
			if texture[1] >= texture[2] then texture[1] = 0 end

			local custom = BSclient.getOverlay(source)
			custom[""..parts[choice]] = { drawables[choice][1],texture[1] }
			BSclient.setOverlay(source,custom)
		end

		local ondrawable = function(player,choice,mod)
			if mod == 0 then
				ontexture(player,choice)
			else
				local drawable = drawables[choice]
				drawable[1] = drawable[1]+mod

				if isprop then
					if drawable[1] >= drawable[2] then drawable[1] = -1
					elseif drawable[1] < -1 then drawable[1] = drawable[2]-1 end 
				else
					if drawable[1] >= drawable[2] then drawable[1] = 0
					elseif drawable[1] < 0 then drawable[1] = drawable[2] end 
				end

				local custom = BSclient.getOverlay(source)
				custom[""..parts[choice]] = { drawable[1],textures[choice][1] }
				BSclient.setOverlay(source,custom)
				local n = BSclient.getTextures(source,drawable[1])
				textures[choice][2] = n

				if textures[choice][1] >= n then
					textures[choice][1] = 0
				end
			end
		end

		for k,v in pairs(parts) do
			drawables[k] = { 0,0 }
			textures[k] = { 0,0 }

			local old_part = old_custom[v]
			if old_part then
				drawables[k][1] = old_part[1]
				textures[k][1] = old_part[2]
			end

			drawables[k][2] = BSclient.getDrawables(source,v)
			textures[k][2] = BSclient.getTextures(source,v)

			menudata[k] = { ondrawable }
		end

		menudata.onclose = function(player)
			local currentCharacterMode = BSclient.getCharacter(player)
			vRP.setUData(user_id,"currentCharacterMode", json.encode(currentCharacterMode))
		end

		menudata["> Resetar"] = { function(player,choice)
			local ok = vRP.request(source,"Tem certeza que deseja <b>resetar</b> a aparência?",30)
			if ok then
				BSclient.resetOverlay(source)
			end
		end }

		vRP.openMenu(source,menudata)
	end
end

local function build_client_barbershops(source)
	local user_id = vRP.getUserId(source)
	if user_id then
		for k,v in pairs(barbershops) do
			local shop,x,y,z = table.unpack(v)

			local function barbershop_enter(source)
				vRPbs.openBarbershop(source,shop)
			end

			local function barbershop_leave(source)
				vRP.closeMenu(source)
			end

			vRPclient._addMarker(source,21,x,y,z-0.6,0.5,0.5,0.4,255,0,0,50,100)
			vRP.setArea(source,"vRP:barbershop"..k,x,y,z,1,1,barbershop_enter,barbershop_leave)
		end
	end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
	if first_spawn then
		build_client_barbershops(source)
	end
end)

AddEventHandler("disney-barbershop:init", function(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		local value = vRP.getUData(user_id,"currentCharacterMode")
		if value ~= nil then
			local custom = json.decode(value) or {}
			BSclient.setCharacter(player,custom)
		end
	end
end)

RegisterCommand('batom',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id,'batom',1) then
		vRPclient._playAnim(source,true,{{"mp_player_int_uppersmoke","mp_player_int_smoke"}},true)
		Wait(2500)
		vRPclient._stopAnim(source,false)
		BSclient.lipOverlay(source,args[1],args[2])
		local currentCharacterMode = BSclient.getCharacter(source)
		vRP.setUData(user_id,"currentCharacterMode", json.encode(currentCharacterMode))
	else 
		TriggerClientEvent("Notify",source,"negado","Você não possui Batom.")
	end
end)

RegisterCommand('blush',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id,'blush',1) then
		vRPclient._playAnim(source,true,{{"mp_player_int_uppersmoke","mp_player_int_smoke"}},true)
		Wait(2500)
		vRPclient._stopAnim(source,false)
		BSclient.blushOverlay(source,args[1],args[2])
		local currentCharacterMode = BSclient.getCharacter(source)
		vRP.setUData(user_id,"currentCharacterMode", json.encode(currentCharacterMode))
	else 
		TriggerClientEvent("Notify",source,"negado","Você não possui Blush.")
	end
end)

RegisterCommand('maquiagem',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id,'maquiagem',1) then
		vRPclient._playAnim(source,true,{{"mp_player_int_uppersmoke","mp_player_int_smoke"}},true)
		Wait(2500)
		vRPclient._stopAnim(source,false)
		BSclient.makeOverlay(source,args[1])
		local currentCharacterMode = BSclient.getCharacter(source)
		vRP.setUData(user_id,"currentCharacterMode", json.encode(currentCharacterMode))
	else 
		TriggerClientEvent("Notify",source,"negado","Você não possui Maquiagem.")
	end
end)

RegisterCommand('lentecontato',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id,'lente-contato',1) then
		vRPclient._playAnim(source,true,{{"misscommon@van_put_on_masks","put_on_mask_ps"}},false)
		Wait(2500)
		vRPclient._stopAnim(source,false)
		BSclient.eyeOverlay(source,args[1])
		local currentCharacterMode = BSclient.getCharacter(source)
		vRP.setUData(user_id,"currentCharacterMode", json.encode(currentCharacterMode))
	else 
		TriggerClientEvent("Notify",source,"negado","Você não possui Lente de Contato.")
	end
end)


--[[
RegisterCommand('cabelo',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	--if vRP.tryGetInventoryItem(user_id,'batom',1) then
		vRPclient._playAnim(source,true,{{"mp_player_int_uppersmoke","mp_player_int_smoke"}},true)
		Wait(2500)
		vRPclient._stopAnim(source,false)
		BSclient.hairOverlay(source,args[1],args[2],args[3])
		local currentCharacterMode = BSclient.getCharacter(source)
		vRP.setUData(user_id,"currentCharacterMode", json.encode(currentCharacterMode))
	--else 
	--	TriggerClientEvent("Notify",source,"negado","Você não possui Batom.")
	--end
end)
]]--
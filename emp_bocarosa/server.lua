local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRPclient = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
emP = {}
Tunnel.bindInterface("emp_bocarosa",emP)
local idgens = Tools.newIDGenerator()
local blips = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
function emP.checkPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	return vRP.hasPermission(user_id,"bocarosa.permissao")
end

function emP.checkPayment()
	local source = source
	local user_id = vRP.getUserId(source)
	local qtde = math.random(2,5)
	if user_id then
		if vRP.getInventoryWeight(user_id)+vRP.getItemWeight("material")*qtde <= vRP.getInventoryMaxWeight(user_id) then
			vRP.giveInventoryItem(user_id,"material",qtde)
			TriggerClientEvent("Notify",source,"sucesso","Você coletou <b>"..qtde.."x Materiais</b>.")
			return true
		end
	end
end
TOOL.Category           = "Falco Prop Protection"
TOOL.Name               = "Share props"
TOOL.Command            = nil
TOOL.ConfigName         = ""

function TOOL:RightClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or CLIENT then return true end

    local ply = self:GetOwner()

    if ent:CPPIGetOwner() ~= ply then
        FPP.Notify(ply, "You do not have the right to share this entity.", false)
        return
    end

    ent.SharePhysgun1 = nil
    ent.ShareGravgun1 = nil
    ent.SharePlayerUse1 = nil
    ent.ShareEntityDamage1 = nil
    ent.ShareToolgun1 = nil

    ent.AllowedPlayers = nil

    FPP.recalculateCanTouch(player.GetAll(), {ent})
    return true
end

local rateLimitShareSettings = CurTime() + 1

if SERVER then
    util.AddNetworkString("FPP_ShareSettings")
end

function TOOL:LeftClick(trace)

    if rateLimitShareSettings > CurTime() then
        return true -- RATE LIMIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
    rateLimitShareSettings = CurTime() + 1

    local ent = trace.Entity
    if not IsValid(ent) or CLIENT then return true end

    local ply = self.GetOwner(self) -- micro-optimization! :trollface:

    if ent:CPPIGetOwner() ~= ply then
        FPP.Notify(ply, "You do not have the right to share this entity.", false)
        return
    end

    local Physgun = ent.SharePhysgun1 or false
    local GravGun = ent.ShareGravgun1 or false
    local PlayerUse = ent.SharePlayerUse1 or false
    local Damage = ent.ShareEntityDamage1 or false
    local Toolgun = ent.ShareToolgun1 or false

    -- This big usermessage will be too big if you select 63 players, since that will not happen I can't be arsed to solve it
    -- ^ DUMB WAY TO DO THINGS (THIS LEADS TO CRASHES) - nick
    
    net.Start("FPP_ShareSettings")
        net.WriteEntity(ent)
        net.WriteBool(Physgun)
        net.WriteBool(GravGun)
        net.WriteBool(PlayerUse)
        net.WriteBool(Damage)
        net.WriteBool(Toolgun)
        net.WriteTable(ent.AllowedPlayers or {})
    net.Send(ply)
    
    return true
end

if CLIENT then
    language.Add( "Tool.shareprops.name", "Share tool" )
    language.Add( "Tool.shareprops.desc", "Change sharing settings per prop" )
    language.Add( "Tool.shareprops.0", "Left click: shares a prop. Right click unshares a prop")
end
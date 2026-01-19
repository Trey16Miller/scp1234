AddCSLuaFile("scp1234/sh_config.lua")
AddCSLuaFile("autorun/client/scp1234_player_cl.lua")
include("scp1234/sh_config.lua")

util.AddNetworkString("SCP1234_Mode")

local function LockTimerId(ent) return "SCP1234P_LOCK_" .. ent:EntIndex() end

local function IsPetrified(ent)
    if not IsValid(ent) then return false end
    return ent:GetNWBool("SCP1234P_Petrified", false)
end

local function MarkPetrified(ent, on)
    if not IsValid(ent) then return end
    ent:SetNWBool("SCP1234P_Petrified", on and true or false)
end

local function SetSCPMode(ply, on)
    ply:SetNWBool("SCP1234P_Mode", on)
    ply:SetNWFloat("SCP1234P_BlinkNext", CurTime() + SCP1234.BlinkInterval)
    ply:SetNWFloat("SCP1234P_BlinkEnd", 0)
end

concommand.Add("scp1234_toggle", function(ply)
    SetSCPMode(ply, not ply:GetNWBool("SCP1234P_Mode", false))
end)

local function HardFreezeNPC(ent)
    if not IsValid(ent) or IsPetrified(ent) then return end

    MarkPetrified(ent, true)

    ent:SetMaterial(SCP1234.StoneMat)
    ent:SetColor(SCP1234.StoneCol)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)

    if ent:IsNPC() or ent:IsNextBot() then
        if ent.Fire then ent:Fire("DisableAI") end
        if ent.ClearSchedule then ent:ClearSchedule() end
        if ent.SetNPCState then ent:SetNPCState(NPC_STATE_IDLE) end
        if ent.SetPlaybackRate then ent:SetPlaybackRate(0) end

        local wep = ent.GetActiveWeapon and ent:GetActiveWeapon()
        if IsValid(wep) then wep:Remove() end
    end

    local pos = ent:GetPos()
    local ang = ent:GetAngles()

    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetVelocity(vector_origin)

    local id = LockTimerId(ent)
    timer.Remove(id)
    timer.Create(id, 0.02, 0, function()
        if not IsValid(ent) then
            timer.Remove(id)
            return
        end

        ent:SetMoveType(MOVETYPE_NONE)
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:SetVelocity(vector_origin)
    end)

    
    timer.Simple(10, function()
        if IsValid(ent) then
            timer.Remove(id)
            ent:Remove() -- NO RAGDOLL
        end
    end)
end

hook.Add("Think", "SCP1234P_PetrifyTouch", function()
    for _, scp in ipairs(player.GetAll()) do
        if not scp:GetNWBool("SCP1234P_Mode", false) then continue end
        if not scp:Alive() then continue end

        local rangeSqr = (SCP1234.PetrifyRange or 70)^2
        local pos = scp:GetPos()

        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) and not IsPetrified(ent) then
                if pos:DistToSqr(ent:GetPos()) <= rangeSqr then
                    HardFreezeNPC(ent)
                end
            end
        end
    end
end)

hook.Add("EntityRemoved", "SCP1234P_ClearLock", function(ent)
    timer.Remove(LockTimerId(ent))
end)

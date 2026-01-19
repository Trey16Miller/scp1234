include("scp1234/sh_config.lua")

net.Receive("SCP1234_Mode", function()
    LocalPlayer().SCP1234P_Mode = net.ReadBool()
end)

hook.Add("HUDPaint", "SCP1234P_HUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if not ply:GetNWBool("SCP1234P_Mode", false) then return end

    local now = CurTime()
    local blinkNext = ply:GetNWFloat("SCP1234P_BlinkNext", 0)
    local blinkEnd = ply:GetNWFloat("SCP1234P_BlinkEnd", 0)
    local inBlink = now < blinkEnd
    local locked = ply:GetNWBool("SCP1234P_Locked", false)

    if locked and not inBlink then
        draw.SimpleTextOutlined(
            "THEY ARE WATCHING",
            "Trebuchet24",
            ScrW() / 2,
            ScrH() * 0.35,
            Color(255, 60, 60),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            2,
            Color(0, 0, 0, 220)
        )
    elseif inBlink then
        draw.SimpleTextOutlined(
            "BLINK",
            "Trebuchet24",
            ScrW() / 2,
            ScrH() * 0.35,
            Color(120, 255, 120),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            2,
            Color(0, 0, 0, 220)
        )
    end

    local w, h = 300, 64
    local x, y = 20, ScrH() - h - 20

    draw.RoundedBox(8, x, y, w, h, Color(0, 0, 0, 170))
    draw.SimpleText("SCP-1234 MODE", "Trebuchet18", x + 10, y + 8, Color(200, 200, 200))

    local cd = math.max(0, blinkNext - now)
    draw.SimpleText(string.format("Next blink: %.1fs", cd), "Trebuchet18", x + 10, y + 34, Color(200, 200, 200))
end)

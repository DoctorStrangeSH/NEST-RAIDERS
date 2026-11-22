local Players = game:GetService("Players")
local player = Players.LocalPlayer

player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
    if player:GetAttribute("ProfileLoaded") then
        print("[NEST RAIDERS] Player profile ready.")
    end
end)

print("[NEST RAIDERS] Client ready for UI controllers.")

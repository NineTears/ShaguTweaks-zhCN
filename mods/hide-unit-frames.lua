local _G = ShaguTweaks.GetGlobalEnv()

local module = ShaguTweaks:register({
    title = "隐藏单位框架",
    description = "[hide-unit-frames]\n如果生命值和魔法值满，没有施法，宠物快乐，没有目标，并且退出战斗，则隐藏玩家和宠物框架。这些框架将鼠标悬停时显示。",
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = "单位框架",
    enabled = nil,
})

module.enable = function(self)
    local frames = { PlayerFrame, PlayerFrameHealthBar, PlayerFrameManaBar, PetFrame }
    local isCasting

    local function ShowFrames()
        for _, frame in pairs(frames) do
            frame:SetAlpha(1)
        end
    end

    local function HideFrames()
        for _, frame in pairs(frames) do
            frame:SetAlpha(0)
        end
    end

    local function FullHealth(unit)
        if UnitHealth(unit) == UnitHealthMax(unit) then return true end
    end

    local function FullMana(unit)
        local powerType = UnitPowerType(unit)
        if not (powerType == 0 or powerType == 3) then return true end  -- 0 = mana, 3 = energy
        if UnitMana(unit) == UnitManaMax(unit) then return true end
    end

    local function HappyPet()
        if not (UnitCreatureType("pet") == "Beast") then 
            return true
        elseif (GetPetHappiness() > 1) then 
            return true
        end
    end

    local function PetConditions()
        if not UnitExists("pet") then return true end
        if HappyPet() and FullHealth("pet") then return true end
    end

    local function PlayerConditions()
        local fullhealth = FullHealth("player")
        local fullmana = FullMana("player")
        local ooc = not UnitAffectingCombat("player")

        if fullhealth and fullmana and (not isCasting) and ooc then return true end
    end

    local function CheckResting()
        if IsResting() then
            PlayerRestGlow:SetAlpha(PlayerFrame:GetAlpha())
        end
    end

    local function CheckConditions()
        local notarget = not UnitExists("target")
        local player = PlayerConditions()
        local pet = PetConditions()

        if notarget and player and pet then 
            HideFrames()
            CheckResting()
        else
            ShowFrames()
            CheckResting()
        end
    end

    for _, frame in pairs(frames) do
        local enter = frame:GetScript("OnEnter")
        frame:SetScript("OnEnter", function()
            ShowFrames()
            CheckResting()          
            enter()
        end)

        local leave = frame:GetScript("OnLeave")
        frame:SetScript("OnLeave", function()
            leave()            
            CheckConditions()
        end)        
    end

    local events = CreateFrame("Frame", nil, UIParent)	
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_TARGET_CHANGED")
    events:RegisterEvent("UNIT_HEALTH", "player")
    events:RegisterEvent("UNIT_HEALTH", "pet")
    events:RegisterEvent("UNIT_MANA", "player")
    events:RegisterEvent("UNIT_ENERGY", "player")
    events:RegisterEvent("SPELLCAST_START", "player")
    events:RegisterEvent("SPELLCAST_CHANNEL_START", "player")
    events:RegisterEvent("SPELLCAST_STOP", "player")
    events:RegisterEvent("SPELLCAST_FAILED", "player")
    events:RegisterEvent("SPELLCAST_INTERRUPTED", "player")
    events:RegisterEvent("SPELLCAST_CHANNEL_STOP", "player")
    events:RegisterEvent("PLAYER_REGEN_DISABLED") -- in combat
    events:RegisterEvent("PLAYER_REGEN_ENABLED") -- out of combat
    events:RegisterEvent("UNIT_PET")

    events:SetScript("OnEvent", function()
        isCasting = nil
        if ((event == "SPELLCAST_START") or (event == "SPELLCAST_CHANNEL_START") or (event == "SPELLCAST_STOP") or (event == "SPELLCAST_CHANNEL_STOP")) then
            isCasting = true
        end
        CheckConditions()   
    end)

    
end
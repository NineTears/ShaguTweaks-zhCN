local _G = ShaguTweaks.GetGlobalEnv()
local rgbhex = ShaguTweaks.rgbhex

local module = ShaguTweaks:register({
    title = "聊天时间戳",
    description = "[chat-timestamps]\n给聊天消息添加时间戳。",
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = "社交&聊天",
    enabled = nil,
})

local function timestamps()
    local left = "["
    local right = "]"
    local timecolor = .8,.8,.8,1
    local timecolorhex = rgbhex(timecolor)

    local function AddMessage(frame, text, a1, a2, a3, a4, a5)
        if not text then return end

        -- show timestamp in chat
        text = timecolorhex .. left .. date("%H:%M:%S") .. right .. "|r " .. text

        frame:HookAddMessage(text, a1, a2, a3, a4, a5)
    end

    for i=1,NUM_CHAT_WINDOWS do            
        _G["ChatFrame"..i].AddMessage = AddMessage
    end
end

module.enable = function(self)
    ShaguTweaks.ChatTimestamps = true
    if ShaguTweaks.ChatTweaksExtended then return end

    -- load after chat tweaks / chat links
    local events = CreateFrame("Frame", nil, UIParent)	
    events:RegisterEvent("PLAYER_ENTERING_WORLD")

    events:SetScript("OnEvent", function()
        if not this.loaded then
            this.loaded = true
            timestamps()
        end
    end)
end

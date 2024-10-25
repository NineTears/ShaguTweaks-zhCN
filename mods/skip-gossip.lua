local module = ShaguTweaks:register({
    title = "跳过NPC对话",
    description = "[skip-gossip]\n跳过与NPC对话，直接进入正题",
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = nil,
    enabled = nil,
})
  
module.enable = function(self)
    local actions = CreateFrame("Frame", nil, UIParent)

    local professions = {
        "battlemaster",
        "taxi",
        "trainer",
        "vendor",
        "banker",
    }    

    local phrases = {
        -- Bank
        "I would like to check my deposit box",
        
        -- Vanilla
        "Teleport me to the Molten Core",

        -- Turtle WoW
        -- Alliance
        "Please open a portal to Alah'Thalas",
        "Please open a portal to Stormwind",
        -- Horde        
        "Open a portal to Amani'Alor",
    }

    local ignore = {
        -- npcs named here will be ignored
        "Goblin Brainwashing Device",
    }

    function actions:Gossip()        
        if actions.gossip then
            local name = GossipFrameNpcNameText:GetText()
            local GossipOptions = {}
            local title
            title,GossipOptions[1],_,GossipOptions[2],_,GossipOptions[3],_,GossipOptions[4],_,GossipOptions[5] = GetGossipOptions()

            if name then
                for _, npc in pairs(ignore) do
                    if name == npc then
                        return true 
                    end
                end               
            end

            for i = 1, 5 do
                if not GossipOptions[i] then break end              
                if GossipOptions[i] == "gossip" then
                    title = string.gsub(title, "%W", "")
                    for _, phrase in pairs(phrases) do
                        phrase = string.gsub(phrase, "%W", "")                        
                        if phrase == title then
                            SelectGossipOption(i)
                            break
                        end
                    end
                else
                    for _, profession in pairs(professions) do
                        if profession == GossipOptions[i] then
                            SelectGossipOption(i)
                            break
                        end
                    end
                end
            end

        end
    end

    actions:RegisterEvent("GOSSIP_SHOW")
    actions:RegisterEvent("GOSSIP_CLOSED")

    actions:SetScript("OnEvent", function()
        if (event == "GOSSIP_SHOW") then
            actions.gossip = true
            if not IsShiftKeyDown() then
                actions:Gossip()
            end
        elseif (event == "GOSSIP_CLOSED") then
            actions.gossip = nil        
        end
    end)    
end
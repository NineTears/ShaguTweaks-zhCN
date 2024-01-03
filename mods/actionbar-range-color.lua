local _G = ShaguTweaks.GetGlobalEnv()
local hooksecurefunc = ShaguTweaks.hooksecurefunc

local module = ShaguTweaks:register({
    title = "超出范围变色",
    description = "[actionbar-range-color]\n当超出技能范围时，动作条按钮将显示为红色。",
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = "界面UI",
    enabled = true,
})

module.enable = function(self)    
    hooksecurefunc("ActionButton_OnUpdate", function(elapsed)
        -- Button color based on range
        if ( this.rangeTimer ) then
            this.rangeTimer = this.rangeTimer - elapsed
            if ( this.rangeTimer <= 0.2 ) then -- 0.1
                if ( IsActionInRange( ActionButton_GetPagedID(this)) == 0 ) then
                    if not this.a then
                        this.r,this.g,this.b,this.a = 1,.1,.1,1 -- out of range colour
                    end
                    _G[this:GetName() .. 'Icon']:SetVertexColor(this.r, this.g, this.b, this.a)
                    elseif IsUsableAction(ActionButton_GetPagedID(this)) then
                        _G[this:GetName() .. 'Icon']:SetVertexColor(1, 1, 1, 1)
                    end
                    this.rangeTimer = TOOLTIP_UPDATE_TIME
                end
            end
    end, true)
end

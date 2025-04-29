pfUI:RegisterModule("uf_blehzui", "vanilla:tbc", function ()
  if C.unitframes.disable == "1" or C.unitframes.layout ~= "blehzui" then return end

  -- update player layout
  local hookUpdateConfigPlayer = pfUI.uf.player.UpdateConfig
  function pfUI.uf.player.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigPlayer(pfUI.uf.player)

    -- load configs
    local rawborder, default_border = GetBorderSize("unitframes")
    local pspacing = C.unitframes.player.pspace * GetPerfectPixel()
    local tspacing = C.unitframes.target.pspace * GetPerfectPixel()

    -- adjust layout
    pfUI.uf.player:UpdateFrameSize()
    pfUI.uf.player:SetFrameStrata("LOW")
    pfUI.uf.player:SetHeight(pfUI.uf.player:GetHeight() + 2*default_border + (C.global.font_size * 1.5) + pspacing)

    pfUI.uf.player.caption = pfUI.uf.player.caption or CreateFrame("Frame", "pfPlayerCaption", pfUI.uf.player)
    pfUI.uf.player.caption:SetHeight(C.global.font_size * 1.5)
    pfUI.uf.player.caption:SetPoint("BOTTOMRIGHT",pfUI.uf.player, "BOTTOMRIGHT",0, 0)
    pfUI.uf.player.caption:SetPoint("BOTTOMLEFT",pfUI.uf.player, "BOTTOMLEFT",0, 0)

    pfUI.uf.player.hpLeftText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpLeftText:ClearAllPoints()
    pfUI.uf.player.hpLeftText:SetPoint("LEFT",pfUI.uf.player.caption, "LEFT", default_border + pfUI.uf.player.config.txthpleftoffx, 0)

    pfUI.uf.player.hpCenterText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpCenterText:ClearAllPoints()
    pfUI.uf.player.hpCenterText:SetPoint("CENTER",pfUI.uf.player.caption, "CENTER", 0, 0)

    --pfUI.uf.player.restIcon:ClearAllPoints()
    --pfUI.uf.player.restIcon:SetPoint("CENTER", pfUI.uf.player.caption, "CENTER", 0, 0)

    local fontname, fontsize, fontstyle
    if pfUI.uf.player.config.customfont == "1" then
      fontname = pfUI.media[pfUI.uf.player.config.customfont_name]
      fontsize = tonumber(pfUI.uf.player.config.customfont_size)
      fontstyle = pfUI.uf.player.config.customfont_style
    else
      fontname = pfUI.font_unit
      fontsize = tonumber(C.global.font_unit_size)
      fontstyle = C.global.font_unit_style
    end
    
    -- Right text goes to the left of the HP bar, double font size.
    pfUI.uf.player.hpRightText:SetFont(fontname, fontsize*2, fontstyle)
    pfUI.uf.player.hpRightText:SetParent(pfUI.uf.player.hp.bar)
    pfUI.uf.player.hpRightText:ClearAllPoints()
    pfUI.uf.player.hpRightText:SetPoint("LEFT",pfUI.uf.player.hp.bar, "LEFT", default_border + pfUI.uf.player.config.txthprightoffx, 0)
    
    pfUI.uf.player.powerRightText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.powerRightText:ClearAllPoints()
    pfUI.uf.player.powerRightText:SetPoint("RIGHT",pfUI.uf.player.caption, "RIGHT", -default_border, 0)

    --pfUI.castbar.player:SetAllPoints(pfUI.uf.player.hp.bar)
    pfUI.castbar.player:SetAllPoints(pfUI.uf.player.caption)

    UpdateMovable(pfUI.castbar.player, true)
    CreateBackdrop(pfUI.uf.player.caption, default_border)
    if pfUI.castbar.player.bar.backdrop_shadow then
      pfUI.castbar.player.bar.backdrop_shadow:Hide()
    end
  end

  -- update target layout
  local hookUpdateConfigTarget = pfUI.uf.target.UpdateConfig
  function pfUI.uf.target.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigTarget(pfUI.uf.target)

    -- load configs
    local rawborder, default_border = GetBorderSize("unitframes")
    local pspacing = C.unitframes.player.pspace
    local tspacing = C.unitframes.target.pspace

    -- adjust layout
    pfUI.uf.target:UpdateFrameSize()
    pfUI.uf.target:SetFrameStrata("LOW")
    pfUI.uf.target:SetHeight(pfUI.uf.target:GetHeight() + 2*default_border + (C.global.font_size * 1.5) + tspacing)

    pfUI.uf.target.caption = pfUI.uf.target.caption or CreateFrame("Frame", "pfTargetCaption", pfUI.uf.target)
    pfUI.uf.target.caption:SetHeight(C.global.font_size * 1.5)
    pfUI.uf.target.caption:SetPoint("BOTTOMRIGHT",pfUI.uf.target,"BOTTOMRIGHT", 0, 0)
    pfUI.uf.target.caption:SetPoint("BOTTOMLEFT",pfUI.uf.target,"BOTTOMLEFT", 0, 0)

    pfUI.uf.target.hpLeftText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpLeftText:ClearAllPoints()
    pfUI.uf.target.hpLeftText:SetPoint("LEFT",pfUI.uf.target.caption, "LEFT", default_border, 0)

    pfUI.uf.target.hpCenterText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpCenterText:ClearAllPoints()
    pfUI.uf.target.hpCenterText:SetPoint("CENTER",pfUI.uf.target.caption, "CENTER", 0, 0)

    local fontname, fontsize, fontstyle
    if pfUI.uf.player.config.customfont == "1" then
      fontname = pfUI.media[pfUI.uf.player.config.customfont_name]
      fontsize = tonumber(pfUI.uf.player.config.customfont_size)
      fontstyle = pfUI.uf.player.config.customfont_style
    else
      fontname = pfUI.font_unit
      fontsize = tonumber(C.global.font_unit_size)
      fontstyle = C.global.font_unit_style
    end

    pfUI.uf.target.hpRightText:SetFont(fontname, fontsize*2, fontstyle)
    pfUI.uf.target.hpRightText:SetParent(pfUI.uf.target.hp.bar)
    pfUI.uf.target.hpRightText:ClearAllPoints()
    pfUI.uf.target.hpRightText:SetPoint("LEFT",pfUI.uf.target.hp.bar, "LEFT", default_border + pfUI.uf.target.config.txthprightoffx, 0)

    pfUI.uf.target.powerRightText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.powerRightText:ClearAllPoints()
    pfUI.uf.target.powerRightText:SetPoint("RIGHT",pfUI.uf.target.caption, "RIGHT", -default_border, 0)

    pfUI.castbar.target:SetAllPoints(pfUI.uf.target.hp.bar)

    UpdateMovable(pfUI.castbar.target, true)
    CreateBackdrop(pfUI.uf.target.caption, default_border)
    if pfUI.castbar.target.bar.backdrop_shadow then
      pfUI.castbar.target.bar.backdrop_shadow:Hide()
    end
  end

  -- trigger updates
  pfUI.uf.player.UpdateConfig()
  pfUI.uf.target.UpdateConfig()
end)

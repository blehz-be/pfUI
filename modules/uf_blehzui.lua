pfUI:RegisterModule("uf_blehzui", "vanilla", function ()
  if C.unitframes.disable == "1" or C.unitframes.layout ~= "blehzui" then return end

  local caption_height_multiplier = 1.2

  local function addBackgroundBar(unitframe, bar)
    if (not unitframe.hpbarbg) then
      DEFAULT_CHAT_FRAME:AddMessage("addBackgroundBar")
      unitframe.hpbarbg = CreateStatusBar(nil, bar)
      unitframe.hpbarbg:SetStatusBarTexture(pfUI.media[unitframe.config.bartexture])
      unitframe.hpbarbg:SetOrientation("HORIZONTAL")
      unitframe.hpbarbg:SetAllPoints(bar)
      unitframe.hpbarbg:SetStatusBarColor(0.2,0.2,0.2,1)
      unitframe.hpbarbg:SetFrameStrata("BACKGROUND")
      unitframe.hpbarbg:SetFrameLevel(bar:GetFrameLevel()+1)
    end
  end

  local function addCaptionToUnitFrame(unitframe)
    local rawborder, default_border = GetBorderSize("unitframes")
    local pspacing = unitframe.config.pspace * GetPerfectPixel()

    unitframe.caption = unitframe.caption or CreateFrame("Frame", "pfPlayerCaption", unitframe)
    CreateBackdrop(unitframe.caption, default_border)
    unitframe.caption:SetHeight(C.global.font_size * caption_height_multiplier)
    unitframe.caption:SetPoint("BOTTOMRIGHT", unitframe, "BOTTOMRIGHT",0, 0)
    unitframe.caption:SetPoint("BOTTOMLEFT", unitframe, "BOTTOMLEFT",0, 0)

    -- adjust layout
    unitframe:UpdateFrameSize()
    unitframe:SetFrameStrata("LOW")
    unitframe:SetHeight(unitframe:GetHeight() + 2*default_border + (unitframe.caption:GetHeight()) + pspacing)

    -- Position the power texts in the caption
    unitframe.powerLeftText:SetParent(unitframe.caption)
    unitframe.powerLeftText:ClearAllPoints()
    unitframe.powerLeftText:SetPoint("LEFT", unitframe.caption, "LEFT", default_border + unitframe.config.txtpowerleftoffx, 0)

    unitframe.powerCenterText:SetParent(unitframe.caption)
    unitframe.powerCenterText:ClearAllPoints()
    unitframe.powerCenterText:SetPoint("CENTER", unitframe.caption, "CENTER", unitframe.config.txtpowercenteroffx, 0)

    unitframe.powerRightText:SetParent(unitframe.caption)
    unitframe.powerRightText:ClearAllPoints()
    unitframe.powerRightText:SetPoint("RIGHT", unitframe.caption, "RIGHT", -default_border - unitframe.config.txtpowerrightoffx, 0)
  end

  local function applyBigFontToUnitFrameText(unitframeconfig, text)
    local fontname, fontsize, fontstyle
    if unitframeconfig.customfont == "1" then
      fontname = pfUI.media[unitframeconfig.customfont_name]
      fontsize = tonumber(unitframeconfig.customfont_size)
      fontstyle = unitframeconfig.customfont_style
    else
      fontname = pfUI.font_unit
      fontsize = tonumber(C.global.font_unit_size)
      fontstyle = C.global.font_unit_style
    end
    text:SetFont(fontname, fontsize*1.8, fontstyle)
  end

  local function hexrgba(str)
    -- Convert '|caarrggbb' to rgba
    local _, _, a, r, g, b = strfind(str or "", "|c(%x%x)(%x%x)(%x%x)(%x%x)")
    if not a then return end
    r, g, b, a = tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255, tonumber(a, 16)/255
    return r, g, b, a
  end

  -- Dirty hack to get the UnitReactionColor in pastel (for my colorblindess)
  for i=1, table.getn(UnitReactionColor) do
    UnitReactionColor[i].r = (UnitReactionColor[i].r + .5 ) * .5
    UnitReactionColor[i].g = (UnitReactionColor[i].g + .5 ) * .5
    UnitReactionColor[i].b = (UnitReactionColor[i].b + .5 ) * .5
  end

  -- Override some colors (use custom power colors, apply pastel to UnitReactionColor) to help with my color blindness
  local hookGetColor = pfUI.uf.target.GetColor
  function myGetColor(self, preset)
    local config = self.config
    local unitstr = self.label .. self.id

    -- Power text color should get the same custom power colors as the bars
    if preset == "power" and config["powercolor"] == "1" then
      local mana = config.defcolor == "0" and config.manacolor or C.unitframes.manacolor
      local rage = config.defcolor == "0" and config.ragecolor or C.unitframes.ragecolor
      local energy = config.defcolor == "0" and config.energycolor or C.unitframes.energycolor
      local focus = config.defcolor == "0" and config.focuscolor or C.unitframes.focuscolor

      local r, g, b, a = .5, .5, .5, 1
      local utype = UnitPowerType(unitstr)
      if utype == 0 then
        r, g, b, a = GetStringColor(mana)
      elseif utype == 1 then
        r, g, b, a = GetStringColor(rage)
      elseif utype == 2 then
        r, g, b, a = GetStringColor(focus)
      elseif utype == 3 then
        r, g, b, a = GetStringColor(energy)
      end

      return pfUI.api.rgbhex(r,g,b,a)
    end

    -- Get the color of the original function first
    local hex_color = hookGetColor(self, preset)

    local apply_pastel = nil

    if preset == "unit" and config["classcolor"] == "1" then
      if not UnitIsPlayer(unitstr) and self.label ~= "pet" then
        apply_pastel = true
      end
    elseif preset == "reaction" and config["classcolor"] == "1" then
      apply_pastel = true
    end

    if apply_pastel then
      local r, g, b, a = hexrgba(hex_color)
      r, g, b = (r + .5) * .5, (g + .5) * .5, (b + .5) * .5
      hex_color = pfUI.api.rgbhex(r,g,b,a)
    end

    return hex_color
  end

  pfUI.uf.player.GetColor = myGetColor
  pfUI.uf.target.GetColor = myGetColor

  -- update player layout
  local hookUpdateConfigPlayer = pfUI.uf.player.UpdateConfig
  function pfUI.uf.player.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigPlayer(pfUI.uf.player)

    -- load configs
    local rawborder, default_border = GetBorderSize("unitframes")

    addCaptionToUnitFrame(pfUI.uf.player)

    -- Left HP text, double font size.
    applyBigFontToUnitFrameText(pfUI.uf.player.config, pfUI.uf.player.hpLeftText)

    -- Create healthbar background bar (visible when hp is lost)
    addBackgroundBar(pfUI.uf.player, pfUI.uf.player.hp)

    --pfUI.uf.player.restIcon:ClearAllPoints()
    --pfUI.uf.player.restIcon:SetPoint("LEFT", pfUI.uf.player.hpLeftText, "LEFT", 0, 0)

    --pfUI.castbar.player:SetAllPoints(pfUI.uf.player.hp.bar)
    pfUI.castbar.player:SetAllPoints(pfUI.uf.player.caption)
    UpdateMovable(pfUI.castbar.player, true)

    if pfUI.castbar.player.bar.backdrop_shadow then
      pfUI.castbar.player.bar.backdrop_shadow:Hide()
    end

    pfUI.bars[1]:ClearAllPoints()
    pfUI.bars[1]:SetPoint("CENTER", UIParent, "CENTER", 0, 240)
    UpdateMovable(pfUI.bars[1], true)

    pfUI.uf.player:ClearAllPoints()
    pfUI.uf.player:SetPoint("TOPRIGHT", pfUI.bars[1], "TOPLEFT", -default_border - 1, -default_border*2)
    UpdateMovable(pfUI.uf.player, true)

  end

  -- update target layout
  local hookUpdateConfigTarget = pfUI.uf.target.UpdateConfig
  function pfUI.uf.target.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigTarget(pfUI.uf.target)

    -- load configs
    local rawborder, default_border = GetBorderSize("unitframes")

    addCaptionToUnitFrame(pfUI.uf.target)

    -- Right HP text, double font size.
    applyBigFontToUnitFrameText(pfUI.uf.target.config, pfUI.uf.target.hpRightText)

    -- Create healthbar background bar (visible when hp is lost)
    addBackgroundBar(pfUI.uf.target, pfUI.uf.target.hp)

    pfUI.castbar.target:SetAllPoints(pfUI.uf.target.hp.bar)
    UpdateMovable(pfUI.castbar.target, true)

    if pfUI.castbar.target.bar.backdrop_shadow then
      pfUI.castbar.target.bar.backdrop_shadow:Hide()
    end

    pfUI.uf.target:ClearAllPoints()
    pfUI.uf.target:SetPoint("TOPLEFT", pfUI.bars[1], "TOPRIGHT", default_border + 1, -default_border*2)
    UpdateMovable(pfUI.uf.target, true)

  end

  -- targettarget
  local hookUpdateConfigTargetTarget = pfUI.uf.targettarget.UpdateConfig
  function pfUI.uf.targettarget.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigTargetTarget(pfUI.uf.targettarget)

    local border = tonumber(C.appearance.border.default)
    pfUI.uf.targettarget:ClearAllPoints()
    pfUI.uf.targettarget:SetPoint("TOPLEFT", pfUI.uf.player, "BOTTOMLEFT", 0, (-border * 2) - 2)
    UpdateMovable(pfUI.uf.targettarget, true)
  end

  -- trigger updates
  pfUI.uf.player.UpdateConfig()
  pfUI.uf.target.UpdateConfig()
  pfUI.uf.targettarget.UpdateConfig()
end)

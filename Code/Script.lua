function AddResourceDisplay(parent, resource, icon)
    XImage:new({
        Id = "idResourceBar"..resource.."Icon",
        Image = icon,
        ImageScale = point(500, 500),
    }, parent)
    XText:new({
        Id = "idResourceBar"..resource.."Display",
        MinWidth = 25,
        TextColor = RGB(255, 255, 255),
        RolloverTextColor = RGB(255, 255, 255),
    }, parent)

end

function AddInfoBar()
    local interface = GetXDialog("InGameInterface")
    if interface['idInfoBar'] then
        -- The resource bar is already there, so this must have been called more
        -- than once
        return
    end
    local this_mod_dir = debug.getinfo(2, "S").source:sub(2, -16)
    local bar = XWindow:new({
        Id = "idInfoBar",
        HAlign = "center",
        VAlign = "top",
        LayoutMethod = "HList",
        Margins = box(0, -1, 0, 0),
        Padding = box(8, 0, 8, 0),
        Background = RGBA(0, 20, 40, 200),
        BorderWidth = 1,
    }, interface)

    local funding_section = XWindow:new({
        Id = "idFundingBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(0, 0, 5, 0),
    }, bar)

    XText:new({
        Id = "idResourceBarFundingDisplay",
        MinWidth = 25,
        TextColor = RGB(255, 255, 255),
        RolloverTextColor = RGB(255, 255, 255),
    }, funding_section)

    funding_section:SetRolloverTitle(T{T{3613, "Funding"}, UICity})
    funding_section:SetRolloverText(T{
        ResourceOverviewObj:GetFundingRollover(),
    })

    local research_section = XWindow:new({
        Id = "idResearchBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(5, 0, 15, 0),
    }, bar)

    AddResourceDisplay(research_section, "Research", "UI/Icons/res_experimental_research.tga")

    research_section:SetRolloverTitle(T{T{357380421238, "Research"}, UICity})
    research_section:SetRolloverText(T{
        ResourceOverviewObj:GetResearchRollover(),
    })

    local grid_resources = XWindow:new({
        Id = "idGridResourceBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(15, 0, 5, 0),
    }, bar)

    AddResourceDisplay(grid_resources, "Power", "UI/Icons/res_electricity.tga")
    AddResourceDisplay(grid_resources, "Air", "UI/Icons/res_oxygen.tga")
    AddResourceDisplay(grid_resources, "Water", "UI/Icons/res_water.tga")

    grid_resources:SetRolloverTitle(T{T{3618, "Grid Resources"}, UICity})
    grid_resources:SetRolloverText(T{
        ResourceOverviewObj:GetGridRollover(),
    })

    local basic_resources = XWindow:new({
        Id = "idBasicResourceBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(5, 0, 5, 0),
    }, bar)

    AddResourceDisplay(basic_resources, "Metals", "UI/Icons/res_metal.tga")
    AddResourceDisplay(basic_resources, "Concrete", "UI/Icons/res_concrete.tga")
    AddResourceDisplay(basic_resources, "Food", "UI/Icons/res_food.tga")
    AddResourceDisplay(basic_resources, "PreciousMetals", "UI/Icons/res_precious_metals.tga")

    basic_resources:SetRolloverTitle(T{T{494, "Basic Resources"}, UICity})
    basic_resources:SetRolloverText(T{
        ResourceOverviewObj:GetBasicResourcesRollover(),
    })

    local advanced_resources = XWindow:new({
        Id = "idAdvancedResourceBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(5, 0, 15, 0),
    }, bar)

    AddResourceDisplay(advanced_resources, "Polymers", "UI/Icons/res_polymers.tga")
    AddResourceDisplay(advanced_resources, "Electronics", "UI/Icons/res_electronics.tga")
    AddResourceDisplay(advanced_resources, "MachineParts", "UI/Icons/res_machine_parts.tga")
    AddResourceDisplay(advanced_resources, "Fuel", "UI/Icons/res_fuel.tga")

    advanced_resources:SetRolloverTitle(T{T{500, "Advanced Resources"}, UICity})
    advanced_resources:SetRolloverText(T{
        ResourceOverviewObj:GetAdvancedResourcesRollover(),
    })

    local colonist_section = XWindow:new({
        Id = "idColonistBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(15, 0, 0, 0),
    }, bar)

    AddResourceDisplay(colonist_section, "AvailableHomes", this_mod_dir.."UI/res_home.tga")
    AddResourceDisplay(colonist_section, "Homeless", this_mod_dir.."UI/res_homeless.tga")
    AddResourceDisplay(colonist_section, "Jobs", this_mod_dir.."UI/res_work.tga")
    AddResourceDisplay(colonist_section, "Unemployed", this_mod_dir.."UI/res_unemployed.tga")

    colonist_section:SetRolloverTitle(T{T{547, "Colonists"}, UICity})
    colonist_section:SetRolloverText(T{"<citizens_rollover>",
        citizens_rollover = GetInfoBarCitizensRollover,
    })
end

-- Largely copied from Dome:GetUISectionCitizensRollover(), with the dome-specific sections removed
function GetInfoBarCitizensRollover()
    if not UICity then
        return
    end
  local ui_on_vacant, ui_off_vacant = GetFreeWorkplaces(UICity)
  local renegades = rawget(ResourceOverviewObj.data, "renegades")
  if not renegades then
    renegades = 0
    for _, dome in ipairs(UICity.labels.Dome) do
      renegades = renegades + (dome.labels.Renegade and #dome.labels.Renegade or 0)
    end
  end
  local free = GetFreeLivingSpace(UICity)
  local texts = {
    T({
      7622,
      "<center><em>Jobs</em>"
    }),
    T({
      548,
      "Unemployed and looking for work<right><colonist(number)>",
      number = UICity.labels.Unemployed and #UICity.labels.Unemployed or 0,
      empty_table
    }),
    T({
      549,
      "Vacant work slots<right><colonist(number)>",
      number = ui_on_vacant
    }),
    T({
      550,
      "Disabled work slots<right><colonist(number)>",
      number = ui_off_vacant
    }),
    T({
      7346,
      "Renegades<right><colonist(number)>",
      number = renegades
    }),
    T({
      7623,
      "<newline><center><em>Living space</em>"
    }),
    T({
      552,
      "Vacant residential slots<right><colonist(number)>",
      number = free
    }),
    T({
      7624,
      "Vacant nursery slots<right><colonist(number)>",
      number = GetFreeLivingSpace(UICity, true) - free
    }),
    T({
      551,
      "Homeless<right><colonist(number)>",
      number = UICity.labels.Homeless and #UICity.labels.Homeless or 0
    }),
  }
  return table.concat(texts, "<newline><left>")
end


-- It seems crazy to have to implement this here, but I can't for the life of me figure out how the
-- game does its thousands formatting. As a consequence, this means that the separator is hardcoded
-- to be a comma :-(
-- Taken from http://lua-users.org/wiki/FormattingNumbers
function FormatIntWithSeparator(int)
    local formatted = int
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

function UpdateGridResourceDisplay(interface, resource)
    if not ResourceOverviewObj then
        -- It's probably just not ready yet
        return
    end
    local produced = ResourceOverview['GetTotalProduced'..resource](ResourceOverviewObj)
    local required = ResourceOverview['GetTotalRequired'..resource](ResourceOverviewObj)
    local net = (produced - required) / 1000
    interface["idResourceBar"..resource.."Display"]:SetText(FormatIntWithSeparator(net))
    if net >= 0 then
        interface["idResourceBar"..resource.."Display"]:SetTextColor(RGB(0, 255, 0))
        interface["idResourceBar"..resource.."Display"]:SetRolloverTextColor(RGB(0, 255, 0))
    else
        interface["idResourceBar"..resource.."Display"]:SetTextColor(RGB(255, 0, 0))
        interface["idResourceBar"..resource.."Display"]:SetRolloverTextColor(RGB(255, 0, 0))
    end
end

function UpdateStandardResourceDisplay(interface, resource)
    local available = ResourceOverviewObj:GetAvailable(resource) / 1000
    interface["idResourceBar"..resource.."Display"]:SetText(FormatIntWithSeparator(available))
end

function UpdateInfoBar()
    if not UICity or not ResourceOverviewObj then
        return
    end

    local interface = GetXDialog("InGameInterface")
    UpdateGridResourceDisplay(interface, "Power")
    UpdateGridResourceDisplay(interface, "Air")
    UpdateGridResourceDisplay(interface, "Water")

    UpdateStandardResourceDisplay(interface, "Metals")
    UpdateStandardResourceDisplay(interface, "Concrete")
    UpdateStandardResourceDisplay(interface, "Food")
    UpdateStandardResourceDisplay(interface, "PreciousMetals")

    UpdateStandardResourceDisplay(interface, "Polymers")
    UpdateStandardResourceDisplay(interface, "Electronics")
    UpdateStandardResourceDisplay(interface, "MachineParts")
    UpdateStandardResourceDisplay(interface, "Fuel")

    interface["idResourceBarResearchDisplay"]:SetText(
                    FormatIntWithSeparator(ResourceOverviewObj:GetEstimatedRP()))

    interface["idResourceBarFundingDisplay"]:SetText(
                    "$"..FormatIntWithSeparator(ResourceOverviewObj:GetFunding() / 1000000).." M")

    local vacancies = FormatIntWithSeparator(GetFreeLivingSpace(UICity))
    local homeless = FormatIntWithSeparator(#(UICity.labels.Homeless or empty_table))
    local jobs = FormatIntWithSeparator(GetFreeWorkplaces(UICity))
    local unemployed = FormatIntWithSeparator(#(UICity.labels.Unemployed or empty_table))
    interface["idResourceBarAvailableHomesDisplay"]:SetText(vacancies)
    interface["idResourceBarHomelessDisplay"]:SetText(homeless)
    interface["idResourceBarJobsDisplay"]:SetText(jobs)
    interface["idResourceBarUnemployedDisplay"]:SetText(unemployed)

    -- When you mouse over an element, its tooltip ('rollover') is updated
    -- automatically, but to have it update while it's open, it needs to be
    -- triggered
    XUpdateRolloverWindow(interface["idGridResourceBar"])
    XUpdateRolloverWindow(interface["idBasicResourceBar"])
    XUpdateRolloverWindow(interface["idAdvancedResourceBar"])
    XUpdateRolloverWindow(interface["idResearchBar"])
    XUpdateRolloverWindow(interface["idColonistBar"])
end

function OnMsg.NewMinute()
    UpdateInfoBar()
end

function OnMsg.UIReady()
    CreateGameTimeThread(function()
        while true do
            WaitMsg("OnRender")
            if ResourceOverviewObj and UICity then
                AddInfoBar()
                UpdateInfoBar()
                break
            end
        end
    end)
end

function OnMsg.LoadGame()
    -- This seems a little ridiculous, but it's the only way I've found to
    -- trigger when the UI is ready after loading a game
    CreateGameTimeThread(function()
        while true do
            WaitMsg("OnRender")
            if GetXDialog("HUD") then
                Msg("UIReady")
                break
            end
        end
    end)
end
function OnMsg.NewMapLoaded()
    Msg("UIReady")
end

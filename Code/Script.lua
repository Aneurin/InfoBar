InfoBar = {}
-- Randomly generated number to start counting from, to generate IDs for translatable strings
InfoBar.StringIdBase = 76827346

function InfoBar:AddResourceDisplay(parent, resource, icon)
    local min_width = self.full_width and 50 or 30
    self["idResourceBar"..resource] = XButton:new({
        Id = "idResourceBar"..resource,
        Background = RGBA(0, 0, 0, 0),
        RolloverBackground = RGBA(0, 0, 0, 0),
        PressedBackground = RGBA(0, 0, 0, 0),
        MouseCursor = false,
        LayoutMethod = "HList",
    }, parent)
    self["idResourceBar"..resource.."Icon"] = XImage:new({
        Id = "idResourceBar"..resource.."Icon",
        Image = icon,
        ImageScale = point(500, 500),
    }, self["idResourceBar"..resource])
    self["idResourceBar"..resource.."Display"] = XText:new({
        Id = "idResourceBar"..resource.."Display",
        MinWidth = min_width,
        TextFont = "HexChoice",
        TextColor = RGB(255, 255, 255),
        RolloverTextColor = RGB(255, 255, 255),
    }, self["idResourceBar"..resource])
end

function InfoBar:AddInfoBar()
    local interface = GetXDialog("InGameInterface")
    if not (interface and ResourceOverviewObj and UICity) then return end
    if interface['idInfoBar'] then
        -- The resource bar is already there, so this must have been called more than once. This
        -- might be a request to rebuild it, so remove the existing one and start again
        self.ready = false
        interface['idInfoBar']:delete()
    end
    self:DeleteClockThread()
    local this_mod_dir = debug.getinfo(2, "S").source:sub(2, -16)
    if not self.y_offset then
        self.y_offset = 0
    end
    self.bar = XWindow:new({
        Id = "idInfoBar",
        VAlign = "top",
        Margins = box(0, self.y_offset - 1, 0, 0),
        Padding = box(8, 0, 8, 0),
        Background = RGBA(0, 20, 40, 200),
        BorderWidth = 1,
    }, interface)
    self.bar:SetScaleModifier(point(self.ui_scale * 10, self.ui_scale * 10))
    if self.full_width then
        self.bar:SetLayoutMethod("Box")
        self.bar:SetHAlign("stretch")
    else
        self.bar:SetLayoutMethod("HList")
        self.bar:SetLayoutHSpacing(35)
        self.bar:SetHAlign("center")
    end

    local left = XWindow:new({
        HAlign = "left",
        LayoutMethod = "HList",
        LayoutHSpacing = 10,
    }, self.bar)
    local funding_section = XWindow:new({
        Id = "idFundingBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        RolloverAnchor = "bottom",
    }, left)

    self.idResourceBarFundingDisplay = XText:new({
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
        RolloverAnchor = "bottom",
    }, left)

    self:AddResourceDisplay(research_section, "Research", "UI/Icons/res_experimental_research.tga")

    research_section:SetRolloverTitle(T{T{357380421238, "Research"}, UICity})
    research_section:SetRolloverText(T{
        ResourceOverviewObj:GetResearchRollover(),
    })

    local centre = XWindow:new({
        HAlign = "center",
        LayoutMethod = "HList",
        LayoutHSpacing = 20,
    }, self.bar)

    if self.full_width then
        centre:SetLayoutHSpacing(60)
    end

    local grid_resources = XWindow:new({
        Id = "idGridResourceBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        RolloverAnchor = "bottom",
    }, centre)

    self:AddResourceDisplay(grid_resources, "Power", "UI/Icons/res_electricity.tga")
    self:AddResourceDisplay(grid_resources, "Air", "UI/Icons/res_oxygen.tga")
    self:AddResourceDisplay(grid_resources, "Water", "UI/Icons/res_water.tga")

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
        RolloverAnchor = "bottom",
    }, centre)

    self:AddResourceDisplay(basic_resources, "Metals", "UI/Icons/res_metal.tga")
    self:AddResourceDisplay(basic_resources, "Concrete", "UI/Icons/res_concrete.tga")
    self:AddResourceDisplay(basic_resources, "Food", "UI/Icons/res_food.tga")
    self:AddResourceDisplay(basic_resources, "PreciousMetals", "UI/Icons/res_precious_metals.tga")

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
        RolloverAnchor = "bottom",
    }, centre)

    self:AddResourceDisplay(advanced_resources, "Polymers", "UI/Icons/res_polymers.tga")
    self:AddResourceDisplay(advanced_resources, "Electronics", "UI/Icons/res_electronics.tga")
    self:AddResourceDisplay(advanced_resources, "MachineParts", "UI/Icons/res_machine_parts.tga")
    self:AddResourceDisplay(advanced_resources, "Fuel", "UI/Icons/res_fuel.tga")

    advanced_resources:SetRolloverTitle(T{T{500, "Advanced Resources"}, UICity})
    advanced_resources:SetRolloverText(T{
        ResourceOverviewObj:GetAdvancedResourcesRollover(),
    })

    local right = XWindow:new({
        HAlign = "right",
        LayoutMethod = "HList",
        LayoutHSpacing = 10,
    }, self.bar)

    local colonist_section = XWindow:new({
        Id = "idColonistBar",
        LayoutMethod = "HList",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        RolloverAnchor = "bottom",
    }, right)

    self:AddResourceDisplay(colonist_section, "AvailableHomes", this_mod_dir.."UI/res_home.tga")
    self:AddResourceDisplay(colonist_section, "Homeless", this_mod_dir.."UI/res_homeless.tga")
    self:AddResourceDisplay(colonist_section, "Jobs", this_mod_dir.."UI/res_work.tga")
    self:AddResourceDisplay(colonist_section, "Unemployed", this_mod_dir.."UI/res_unemployed.tga")

    colonist_section:SetRolloverTitle(T{
        T{892778823326, "<nbsp>Colonists<right><colonist(ColonistCount)>"},
        ResourceOverviewObj
    })
    colonist_section:SetRolloverText(T{"<citizens_rollover>",
        citizens_rollover = GetInfoBarCitizensRollover,
    })

    local resources = {
        "Metals", "Concrete", "Food", "PreciousMetals",
        "Polymers", "Electronics", "MachineParts", "Fuel"
    }
    for _, resource in ipairs(resources) do
        self["idResourceBar"..resource]:SetMouseCursor("UI/Cursors/Rollover.tga")
        self["idResourceBar"..resource].OnPress = function()
            InfoBar.SelectNextObjectWithResource(resource)
        end
    end

    self.idResourceBarHomeless:SetMouseCursor("UI/Cursors/Rollover.tga")
    self.idResourceBarHomeless.OnPress = function()
        local colonist = UICity.labels.Homeless and UICity.labels.Homeless[1]
        if IsValid(colonist) then
            colonist:Select(HomelessCycle)
        end
    end
    self.idResourceBarUnemployed:SetMouseCursor("UI/Cursors/Rollover.tga")
    self.idResourceBarUnemployed.OnPress = function()
        local colonist = UICity.labels.Unemployed and UICity.labels.Unemployed[1]
        if IsValid(colonist) then
            colonist:Select(UnemployedCycle)
        end
    end

    local clock_container
    if self.show_mars_time or self.show_clock then
        clock_container = XWindow:new({
            LayoutMethod = "HList",
            LayoutHSpacing = 10,
        }, self.bar)
        if self.full_width then
            clock_container:SetDock("right")
            clock_container:SetMargins(box(20, 0, 0, 0))
        end
    end

    if self.show_mars_time then
        self.mars_clock = XText:new({
            TextFont = "HexChoice",
            TextHAlign = "center",
            TextColor = RGB(255, 255, 255),
            RolloverTextColor = RGB(255, 255, 255),
        }, clock_container)
    end

    if self.show_clock then
        local min_width = (self.show_clock == "seconds") and 75 or 50
        self.clock = XText:new({
            MinWidth = min_width,
            TextFont = "HexChoice",
            TextHAlign = "center",
            HAlign = "right",
            TextColor = RGB(255, 255, 255),
            RolloverTextColor = RGB(255, 255, 255),
        }, clock_container)
        self:StartClockThread()
    end
    self.ready = true
end

-- Largely copied from Dome:GetUISectionCitizensRollover(), with the dome-specific sections removed
function GetInfoBarCitizensRollover()
    if not (ResourceOverviewObj and UICity) then return end
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
    T{
      7622,
      "<center><em>Jobs</em>"
    },
    T{
      548,
      "Unemployed and looking for work<right><colonist(number)>",
      number = UICity.labels.Unemployed and #UICity.labels.Unemployed or 0,
      empty_table
    },
    T{
      549,
      "Vacant work slots<right><colonist(number)>",
      number = ui_on_vacant
    },
    T{
      550,
      "Disabled work slots<right><colonist(number)>",
      number = ui_off_vacant
    },
    T{
      7346,
      "Renegades<right><colonist(number)>",
      number = renegades
    },
    T{
      7623,
      "<newline><center><em>Living space</em>"
    },
    T{
      552,
      "Vacant residential slots<right><colonist(number)>",
      number = free
    },
    T{
      7624,
      "Vacant nursery slots<right><colonist(number)>",
      number = GetFreeLivingSpace(UICity, true) - free
    },
    T{
      551,
      "Homeless<right><colonist(number)>",
      number = UICity.labels.Homeless and #UICity.labels.Homeless or 0
    },
    T{553, "<newline><center><em>Age Groups</em>"},
    ResourceOverviewObj:GetAgeGroupsText(),
  }
  return table.concat(texts, "<newline><left>")
end

function InfoBar.ObjectHasResource(obj, resource)
    if type(obj.stockpiled_amount) == "table" and (obj.stockpiled_amount[resource] or 0) > 0 then
        return true
    elseif obj.resource == resource and (obj.amount or 0) > 0 then
        return true
    elseif obj.producers and obj.producers[resource] and (obj.producers[resource].total_stockpiled or 0) > 0 then
        return true
    end
    return false
end

function InfoBar.GetObjectsWithResource(resource)
    if not UICity then return {} end
    local by_obj = {}
    local by_idx = {}
    local idx = 0
    -- Spaceship comes under ResourceStockpile, transport under Unit and ResourceStockpile, drones
    -- under Unit, producers under Building, storage under ResourceStockpile and Building, but
    -- CargoShuttle is its own thing.
    for _, label in ipairs({'ResourceStockpile', 'Building', 'CargoShuttle', 'Unit'}) do
        for _, obj in pairs(UICity.labels[label] or {}) do
            if InfoBar.ObjectHasResource(obj, resource) then
                -- Check if we've already found this (it may come under two labels that we've looked
                -- at)
                if not by_obj[obj] then
                    idx = idx + 1
                    by_obj[obj] = idx
                    by_idx[idx] = obj
                end
            end
        end
    end
    return by_obj, by_idx
end

function InfoBar.SelectNextObjectWithResource(resource)
    local by_obj, by_idx = InfoBar.GetObjectsWithResource(resource)
    local count = #by_idx
    local idx = (by_obj[SelectedObj] or 0) + 1
    if idx > count then
        idx = 1
    end
    SelectObj(by_idx[idx])
    ViewObjectMars(by_idx[idx])
end

function InfoBar.AbbrevInt(int)
    if int > 10000 then
        return string.format("%dk", floatfloor(int/1000))
    elseif int > 1000 and (int % 1000) > 100 then
        return string.format("%d%s%dk", floatfloor(int/1000), InfoBar.decimal,
            floatfloor((int % 1000) / 100))
    elseif int > 1000 then
        return string.format("%.0fk", int/1000)
    else
        return string.format("%d", int)
    end
end

function InfoBar:UpdateGridResourceDisplay(resource)
    if not ResourceOverviewObj then
        -- It's probably just not ready yet
        return
    end
    local produced = ResourceOverview['GetTotalProduced'..resource](ResourceOverviewObj)
    local required = ResourceOverview['GetTotalRequired'..resource](ResourceOverviewObj)
    if produced == nil or required == nil then
        -- ResourceOverviewObj is here, but it doesn't seem to be usable yet
        return
    end
    local net = (produced - required) / 1000
    local text = net >= 0 and "<green><net>" or "<red><net>"
    if self.show_grid_stock then
        text = text.."<white> (<stored>)"
    end
    self["idResourceBar"..resource.."Display"]:SetText(T{
        text,
        net=self.FormatInt(net),
        stored=self.FormatInt(
            ResourceOverview['GetTotalStored'..resource](ResourceOverviewObj) / 1000
        )
    })
end

function InfoBar:UpdateStandardResourceDisplay(resource)
    if not ResourceOverviewObj.data[resource] then
        -- the object is here, but it doesn't seem to be initialised yet
        return
    end
    local available = ResourceOverviewObj:GetAvailable(resource) / 1000
    self["idResourceBar"..resource.."Display"]:SetText(self.FormatInt(available))
end

function InfoBar:Update()
    if not self.ready then return end

    local interface = GetXDialog("InGameInterface")
    if not interface then return end

    self:UpdateGridResourceDisplay("Power")
    self:UpdateGridResourceDisplay("Air")
    self:UpdateGridResourceDisplay("Water")

    self:UpdateStandardResourceDisplay("Metals")
    self:UpdateStandardResourceDisplay("Concrete")
    self:UpdateStandardResourceDisplay("Food")
    self:UpdateStandardResourceDisplay("PreciousMetals")

    self:UpdateStandardResourceDisplay("Polymers")
    self:UpdateStandardResourceDisplay("Electronics")
    self:UpdateStandardResourceDisplay("MachineParts")
    self:UpdateStandardResourceDisplay("Fuel")

    self["idResourceBarResearchDisplay"]:SetText(
                    self.FormatInt(ResourceOverviewObj:GetEstimatedRP()))

    self["idResourceBarFundingDisplay"]:SetText(
                    "$"..LocaleInt(ResourceOverviewObj:GetFunding() / 1000000).." M")

    local vacancies = self.FormatInt(GetFreeLivingSpace(UICity))
    local homeless = self.FormatInt(#(UICity.labels.Homeless or empty_table))
    local jobs = self.FormatInt(GetFreeWorkplaces(UICity))
    local unemployed = self.FormatInt(#(UICity.labels.Unemployed or empty_table))
    self["idResourceBarAvailableHomesDisplay"]:SetText(vacancies)
    self["idResourceBarHomelessDisplay"]:SetText(homeless)
    self["idResourceBarJobsDisplay"]:SetText(jobs)
    self["idResourceBarUnemployedDisplay"]:SetText(unemployed)

    -- When you mouse over an element, its tooltip ('rollover') is updated
    -- automatically, but to have it update while it's open, it needs to be
    -- triggered
    XUpdateRolloverWindow(interface["idGridResourceBar"])
    XUpdateRolloverWindow(interface["idBasicResourceBar"])
    XUpdateRolloverWindow(interface["idAdvancedResourceBar"])
    XUpdateRolloverWindow(interface["idResearchBar"])
    XUpdateRolloverWindow(interface["idColonistBar"])

    if self.show_mars_time then
        local shift_names = {
            T{541987944858, "First Shift"},
            T{159665176435, "Second Shift"},
            T{994186128274, "Night shift"}
        }
        self.mars_clock:SetText(T{InfoBar.StringIdBase + 21,"<shift> (<hour>h)",
            shift = shift_names[CurrentWorkshift],
            hour = GetTimeOfDay(),
        })
    end
end

function InfoBar.SetScrollSensitivity(sensitivity)
    cameraRTS.SetProperties(1, {ScrollBorder = sensitivity})
    const.DefaultCameraRTS.ScrollBorder = sensitivity
end

function InfoBar:StartClockThread()
    self:DeleteClockThread()
    if not self.show_clock then return end
    local format, tick_time
    if self.show_clock == "seconds" then
        format = "%H:%M:%S"
        -- we need to tick a lot more than once per second to avoid having visibly varying second
        -- times depending on whether we tick just before the second or just after
        tick_time = 100
    else
        format = "%H:%M"
        tick_time = 1000
    end
    self.clock_thread = CreateRealTimeThread(function()
        while true do
            if self.clock then
                self.clock:SetText(os.date(format, os.time()))
                Sleep(tick_time)
            else
                Halt()
            end
        end
    end)
end

function InfoBar:DeleteClockThread()
    if self.clock_thread and IsValidThread(self.clock_thread) then
        DeleteThread(self.clock_thread)
    end
end

function OnMsg.NewMinute()
    InfoBar:Update()
end

function OnMsg.TechResearched()
    -- This is to make sure the rollover templates are updated when you get a new tech that might
    -- affect them, like the one that converts excess power into research.
    InfoBar:AddInfoBar()
    InfoBar:Update()
end

function OnMsg.UIReady()
    CreateGameTimeThread(function()
        while true do
            WaitMsg("OnRender")
            if ResourceOverviewObj and UICity then
                InfoBar.FormatInt = LocaleInt
                InfoBar.ui_scale = 100
                if rawget(_G, "ModConfig") then
                    InfoBar.full_width = ModConfig:Get("InfoBar", "FullWidth")
                    InfoBar.show_clock = ModConfig:Get("InfoBar", "Clock")
                    InfoBar.y_offset = ModConfig:Get("InfoBar", "YOffset")
                    InfoBar.show_grid_stock = ModConfig:Get("InfoBar", "ShowGridStock")
                    InfoBar.ui_scale = ModConfig:Get("InfoBar", "UIScale")
                    InfoBar.show_mars_time = ModConfig:Get("InfoBar", "MarsClock")
                    if ModConfig:Get("InfoBar", "AbbrevResources") then
                        InfoBar.FormatInt = InfoBar.AbbrevInt
                    end
                end
                InfoBar:AddInfoBar()
                InfoBar:Update()
                break
            end
        end
    end)
end

function OnMsg.ModConfigReady()
    ModConfig:RegisterMod("InfoBar", T{InfoBar.StringIdBase, "Info Bar"})
    ModConfig:RegisterOption("InfoBar", "OptionalFeatures", {
        name = T{
            InfoBar.StringIdBase + 22, "<em><center><scale 1100>Optional Features"
        },
        type = "note",
        order = 9,
    })
    ModConfig:RegisterOption("InfoBar", "UIAdjustmentHeader", {
        name = T{
            InfoBar.StringIdBase + 23, "<em><center><scale 1100>Interface Adjustments"
        },
        type = "note",
        order = 29,
    })
    ModConfig:RegisterOption("InfoBar", "FullWidth", {
        name = T{
            InfoBar.StringIdBase + 1, "Full Width Bar"
        },
        desc = T{
            InfoBar.StringIdBase + 2,
            "If everything feels too cramped, make the Info Bar take the full width of the screen"
            .." with more spacing between elements."
        },
        type = "boolean",
        default = false,
        order = 30,
    })
    local screen_scroll_default = const.DefaultCameraRTS.ScrollBorder
    ModConfig:RegisterOption("InfoBar", "ScrollSensitivity", {
        name = T{
            InfoBar.StringIdBase + 3, "Screen Scroll Sensitivity"
        },
        desc = T{
            InfoBar.StringIdBase + 4,
            "Controls how sensitive the game is to scrolling the map when you move your cursor to"
            .." the edge of the screen."
        },
        type = "enum",
        values= {
            {value = screen_scroll_default, label = T{1000121, "Default"}},
            {value = 1, label = T{InfoBar.StringIdBase + 5, "Minimum"}},
            {value = 0, label = T{InfoBar.StringIdBase + 6, "Disabled"}}
        },
        default = screen_scroll_default,
        order = 40,
    })
    ModConfig:RegisterOption("InfoBar", "Clock", {
        name = T{
            InfoBar.StringIdBase + 7, "Show a Clock"
        },
        desc = T{
            InfoBar.StringIdBase + 8, "Add a real time clock to the right of the bar."
        },
        type = "enum",
        values= {
            {value = false, label = T{InfoBar.StringIdBase + 6, "Disabled"}},
            {value = "minutes", label = T{InfoBar.StringIdBase + 9, "Minutes"}},
            {value = "seconds", label = T{InfoBar.StringIdBase + 10, "Seconds"}}
        },
        default = false,
        order = 20,
    })
    ModConfig:RegisterOption("InfoBar", "YOffset", {
        name = T{
            InfoBar.StringIdBase + 11, "Move the Bar Down"
        },
        desc = T{
            InfoBar.StringIdBase + 12, "Add an offset to the bar's vertical position, to make room"
            .." for the Cheats Menu, for example."
        },
        type = "number",
        min = 0,
        default = 0,
        order = 30,
    })
    -- There's a translation specified for the thousands separator, but not for the decimal point.
    -- In practice, the usual situation is that they're either dot or comma, so we can make a pretty
    -- good guess by looking at what's used for the thousands separator.
    if _InternalTranslate(T{1000685, ","}) == "," then
        -- The thousands separator is a comma, which implies that the decimal must use a dot
        InfoBar.decimal = '.'
    else
        -- The thousands separator is presumably either a dot or a space
        InfoBar.decimal = ','
    end
    ModConfig:RegisterOption("InfoBar", "AbbrevResources", {
        name = T{
            InfoBar.StringIdBase + 13, "Abbreviate Resource Counts"
        },
        desc = T{
            InfoBar.StringIdBase + 14, "When resource counts are over a thousand, show them in"
            .." shortened form (1<decimal>2k, 6k, etc).", decimal=InfoBar.decimal
        },
        type = "boolean",
        default = false,
        order = 30,
    })
    ModConfig:RegisterOption("InfoBar", "ShowGridStock", {
        name = T{
            InfoBar.StringIdBase + 15, "Show Stored Grid Resources"
        },
        desc = T{
            InfoBar.StringIdBase + 16, "In the Grid Resources section, show the current storage in"
            .." addition to the surplus/deficit."
        },
        type = "boolean",
        default = false,
        order = 10,
    })
    ModConfig:RegisterOption("InfoBar", "UIScale", {
        name = T{InfoBar.StringIdBase + 17, "Set Custom Scale"},
        desc = T{InfoBar.StringIdBase + 18, "Change the scale of the Info Bar, independently of"
            .." the main game UI scale."},
        label = "<percent(value)>",
        type = "slider",
        default = 100,
        min = 50,
        max = 200,
        step = 10,
        order = 30,
    })
    ModConfig:RegisterOption("InfoBar", "MarsClock", {
        name = T{InfoBar.StringIdBase + 19, "Show Work Shift/Mars Time"},
        desc = T{InfoBar.StringIdBase + 20, "Show the active work shift and the time on Mars."},
        order = 20,
    })
    -- Since this mod doesn't require ModConfig, it can't wait about for it and therefore might have
    -- already created the bar with the default settings, so we need to check
    InfoBar.full_width = ModConfig:Get("InfoBar", "FullWidth")
    InfoBar.show_clock = ModConfig:Get("InfoBar", "Clock")
    InfoBar.y_offset = ModConfig:Get("InfoBar", "YOffset")
    InfoBar.show_grid_stock = ModConfig:Get("InfoBar", "ShowGridStock")
    InfoBar.ui_scale = ModConfig:Get("InfoBar", "UIScale")
    InfoBar.show_mars_time = ModConfig:Get("InfoBar", "MarsClock")
    if ModConfig:Get("InfoBar", "AbbrevResources") then
        InfoBar.FormatInt = InfoBar.AbbrevInt
    else
        InfoBar.FormatInt = LocaleInt
    end
    if InfoBar.full_width or InfoBar.clock or InfoBar.y_offset then
        InfoBar:AddInfoBar()
        InfoBar:Update()
    end
    InfoBar.SetScrollSensitivity(ModConfig:Get("InfoBar", "ScrollSensitivity"))
end

function OnMsg.ModConfigChanged(mod_id, option_id, value)
    if mod_id == "InfoBar"  then
        if option_id == "FullWidth" then
            InfoBar.full_width = value
        elseif option_id == "ScrollSensitivity" then
            InfoBar.SetScrollSensitivity(value)
            return
        elseif option_id == "Clock" then
            InfoBar.show_clock = value
        elseif option_id == "YOffset" then
            InfoBar.y_offset = value
        elseif option_id == "ShowGridStock" then
            InfoBar.show_grid_stock = value
        elseif option_id == "AbbrevResources" then
            if value then
                InfoBar.FormatInt = InfoBar.AbbrevInt
            else
                InfoBar.FormatInt = LocaleInt
            end
        elseif option_id == "UIScale" then
            InfoBar.ui_scale = value
        elseif option_id == "MarsClock" then
            InfoBar.show_mars_time = value
        end
        InfoBar:AddInfoBar()
        InfoBar:Update()
    end
end

-- The following three functions are intended to simplify the job of knowing when it's safe to start
-- inserting new items into the UI, by firing a "UIReady" message. They use the "g_UIReady" global
-- to record when this message has been sent, in order to make it possible to include the same code
-- in multiple mods without ending up with the message sent multiple times.
if rawget(_G, "g_UIReady") == nil then
    -- Check _G explicitly, to avoid the "Attempt to use an undefined global 'g_UIReady'" error
    g_UIReady = false
end
function OnMsg.LoadGame()
    if not g_UIReady then
        -- This seems a little ridiculous, but it's the only way I've found to
        -- trigger when the UI is ready after loading a game
        CreateGameTimeThread(function()
            while true do
                WaitMsg("OnRender")
                if GetXDialog("HUD") then
                    if not g_UIReady then
                        g_UIReady = true
                        Msg("UIReady")
                    end
                    break
                end
            end
        end)
    end
end
function OnMsg.NewMapLoaded()
    if not g_UIReady then
        g_UIReady = true
        Msg("UIReady")
    end
end
-- If we change maps (via loading or returning to the main menu and stating a new game) then the UI
-- will be rebuilt, so we need to allow UIReady to fire again when the time comes.
function OnMsg.DoneMap()
    g_UIReady = false
end

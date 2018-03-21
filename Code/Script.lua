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

    local grid_resources = XWindow:new({
        Id = "idGridResourceBar",
        LayoutMethod = "HList",
        HAlign = "left",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(0, 0, 0, 0),
    }, bar)

    AddResourceDisplay(grid_resources, "Power", "UI/Icons/res_electricity.tga")
    AddResourceDisplay(grid_resources, "Air", "UI/Icons/res_oxygen.tga")
    AddResourceDisplay(grid_resources, "Water", "UI/Icons/res_water.tga")

    grid_resources:SetRolloverTitle(T{T{3618, "Grid Resources"}, UICity})
    grid_resources:SetRolloverText(T{
        ResourceOverviewObj:GetGridRollover(),
        UICity,
    })

    local basic_resources = XWindow:new({
        Id = "idBasicResourceBar",
        LayoutMethod = "HList",
        HAlign = "center",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(10, 0, 10, 0),
    }, bar)

    AddResourceDisplay(basic_resources, "Metals", "UI/Icons/res_metal.tga")
    AddResourceDisplay(basic_resources, "Concrete", "UI/Icons/res_concrete.tga")
    AddResourceDisplay(basic_resources, "Food", "UI/Icons/res_food.tga")
    AddResourceDisplay(basic_resources, "PreciousMetals", "UI/Icons/res_precious_metals.tga")

    basic_resources:SetRolloverTitle(T{T{494, "Basic Resources"}, UICity})
    basic_resources:SetRolloverText(T{
        ResourceOverviewObj:GetBasicResourcesRollover(),
        UICity,
    })

    local advanced_resources = XWindow:new({
        Id = "idAdvancedResourceBar",
        LayoutMethod = "HList",
        HAlign = "right",
        VAlign = "center",
        HandleMouse = true,
        RolloverTemplate = "Rollover",
        Padding = box(0, 0, 0, 0),
    }, bar)

    AddResourceDisplay(advanced_resources, "Polymers", "UI/Icons/res_polymers.tga")
    AddResourceDisplay(advanced_resources, "Electronics", "UI/Icons/res_electronics.tga")
    AddResourceDisplay(advanced_resources, "MachineParts", "UI/Icons/res_machine_parts.tga")
    AddResourceDisplay(advanced_resources, "Fuel", "UI/Icons/res_fuel.tga")

    advanced_resources:SetRolloverTitle(T{T{500, "Advanced Resources"}, UICity})
    advanced_resources:SetRolloverText(T{
        ResourceOverviewObj:GetAdvancedResourcesRollover(),
        UICity,
    })
end

-- It seems crazy to have to implement this here, but I can't for the life of me figure out how the
-- game does its thousands formatting. As a consequence, this means that the separator is hardcoded
-- to be a comma :-(
-- Taken from http://lua-users.org/wiki/FormattingNumbers
function FormatIntWithSeparator(int)
    local formatted = int
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
    if not UICity then
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

    -- When you mouse over an element, its tooltip ('rollover') is updated
    -- automatically, but to have it update while it's open, it needs to be
    -- triggered
    XUpdateRolloverWindow(interface["idGridResourceBar"])
    XUpdateRolloverWindow(interface["idBasicResourceBar"])
    XUpdateRolloverWindow(interface["idAdvancedResourceBar"])
end

function OnMsg.NewMinute()
    UpdateInfoBar()
end

function OnMsg.UIReady()
    AddInfoBar()
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

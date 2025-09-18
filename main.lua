local Dispatcher = require("dispatcher")  -- luacheck:ignore
local Event = require("ui/event")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local DictionaryMode = WidgetContainer:extend{
    name = "dictionarymode",
    is_doc_only = false,
}

function DictionaryMode:onDispatcherRegisterActions()
    Dispatcher:registerAction("dictionarymode_action", {category="none", event="DictionaryMode", title=_("Dictionary Mode"), general=true,})
end

function DictionaryMode:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)

    self:registerTap()
end

function DictionaryMode:toggle()
    local enabled = G_reader_settings:isTrue("enable_dictionary_mode")
    G_reader_settings:saveSetting("enable_dictionary_mode", not enabled)
end

function DictionaryMode:addToMainMenu(menu_items)
    menu_items.dictionarymode = {
        text = _("Dictionary Mode"),
        sorting_hint = "taps_and_gestures",
        checked_func = function()
            return G_reader_settings:isTrue("enable_dictionary_mode")
        end,
        callback = function()
            self:toggle()
        end,
    }
end

function DictionaryMode:onDictionaryMode()
    self:toggle()

    local text = _("Dictionary mode disabled")

    if G_reader_settings:isTrue("enable_dictionary_mode") then
        text = _("Dictionary mode enabled")
    end

    local popup = InfoMessage:new{
        text = text,
    }

    UIManager:show(popup)
end

function DictionaryMode:registerTap()
    self.ui:registerTouchZones({
        {
            id = "dictionarymode_tap",
            ges = "tap",
            screen_zone = {
                ratio_x = 0, ratio_y = 0, ratio_w = 1, ratio_h = 1,
            },
            overrides = {
                "readerhighlight_tap",
                "tap_top_left_corner",
                "tap_top_right_corner",
                "tap_left_bottom_corner",
                "tap_right_bottom_corner",
                "readerfooter_tap",
                "readerconfigmenu_ext_tap",
                "readerconfigmenu_tap",
                "readermenu_ext_tap",
                "readermenu_tap",
                "tap_forward",
                "tap_backward",
            },
            handler = function(ges) return self:onTap(nil, ges) end
        },
    })
end

function DictionaryMode:cleanupSelectedText(text)
    -- Trim spaces and new lines at start and end
    text = text:gsub("^[\n%s]*", "")
    text = text:gsub("[\n%s]*$", "")
    -- Trim spaces around newlines
    text = text:gsub("%s*\n%s*", "\n")
    -- Trim consecutive spaces (that would probably have collapsed
    -- in rendered CreDocuments)
    text = text:gsub("%s%s+", " ")

    return text
end

function DictionaryMode:registerTap()
    local content_left = self.view.content_left or 0
    local content_right = self.view.content_right or self.view.full_width
    local screen_width = self.view.full_width

    local ratio_x = content_left / screen_width
    local ratio_w = (content_right - content_left) / screen_width

    self.ui:registerTouchZones({
        {
            id = "dictionarymode_tap",
            ges = "tap",
            screen_zone = {
                ratio_x = ratio_x,
                ratio_y = 0,
                ratio_w = ratio_w,
                ratio_h = 1,
            },
            overrides = {
                "readerhighlight_tap",
                "tap_top_left_corner",
                "tap_top_right_corner",
                "tap_left_bottom_corner",
                "tap_right_bottom_corner",
                "readerfooter_tap",
                "readerconfigmenu_ext_tap",
                "readerconfigmenu_tap",
                "readermenu_ext_tap",
                "readermenu_tap",
                "tap_forward",
                "tap_backward",
            },
            handler = function(ges) return self:onTap(nil, ges) end
        },
    })
end

return DictionaryMode

local utility = require("util")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

local THIS = {}

local icon = { --- {{{
    ["Charging"] = {
        [100] = '',
        [90] = '',
        [80] = '',
        [70] = '',
        [60] = '',
        [50] = '',
        [40] = '',
        [30] = '',
        [20] = '',
        [10] = '',
        [0] = '',
    },
    ["Discharging"] = {
        [100] = '',
        [90] = '',
        [80] = '',
        [70] = '',
        [60] = '',
        [50] = '',
        [40] = '',
        [30] = '',
        [20] = '',
        [10] = '',
        [0] = '',
    },
    ["Full"] = {
        [100] = '',
    }
} --- }}}

function THIS.battery(name, timeout)
    local battery_widget = wibox.widget {
        {
            {
                id = "status",
                text = "",
                widget = wibox.widget.textbox
            },
            id = "inner",
            {
                id = "capacity",
                text = "0%",
                widget = wibox.widget.textbox
            },
            layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.background,
        set_battery = function(self, val)
            local value = tonumber(val.capacity:match("^%s*(.-)%s*$"))
            local state = val.status:match("^%s*(.-)%s*$")
            if value < 15 and state == "Discharging" then
                naughty.notify({text="RUNNING OUT BATTERY!", timeout=timeout, bg = beautiful.bg_urgent})
            end
            self.inner.status.text = (icon[state][(value // 10) * 10])
            self.inner.capacity.text = value .. "%"
        end,
    }
    gears.timer {
        timeout = timeout,
        call_now = true,
        autostart = true,
        callback = function()
            local info = utility.dirtable('/sys/class/power_supply/' .. name, {'capacity', 'status'})
            battery_widget.battery = info
        end
    }
    return battery_widget
end

return THIS

-- vim: foldenable:foldmethod=marker

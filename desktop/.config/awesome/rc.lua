-- {{{ Required libraries
local gears         = require("gears")
local awful         = require("awful")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local switcher      = require("awesome-switcher")
local awfs          = require("awesome-fullscreen")
local battery 	    = require("awesome-upower-battery")
require("awful.autofocus")
require("awesome-remember-geometry")
-- }}}

-- {{{ Notifications
local function log(msg)
	naughty.notify({
		preset = naughty.config.presets.normal,
		title = "LOG",
		text = msg
	})
end

local function err(msg)
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "ERROR",
		text = msg
	})
end
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
	err(awesome.startup_errors)
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(e)
		if in_error then
			return
		end
		in_error = true
		err(tostring(e))
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(awful.util.get_configuration_dir() .. "themes/berlam/theme.lua")

-- switcher
local function hex2rgba(hex)
	local hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), 1
end
switcher.settings.preview_box_bg = beautiful.border_focus .. "AA"
switcher.settings.preview_box_border = beautiful.bg_focus .. "00"
switcher.settings.preview_box_delay = 150
switcher.settings.preview_box_title_font = {beautiful.font_name}
switcher.settings.preview_box_title_font_size_factor = 1
switcher.settings.preview_box_title_color = {hex2rgba(beautiful.fg_focus)}

-- common
local modkey     = "Mod4"
local altkey     = "Mod1"
local terminal   = "alacritty" or "urxvtc" or "xterm"
local editor     = os.getenv("EDITOR") or "nano" or "vi"

-- user defined
local browser    = os.getenv("BROWSER") or "google-chrome" or "firefox" or "chromium"
local gui_editor = "code" or "atom" or "gvim"
local graphics   = "gimp"
local tagnames   = { "", "!#" }

-- table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

-- lain
lain.layout.termfair.nmaster        = 3
lain.layout.termfair.ncol           = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol    = 1
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ theme = { width = 250 } })
		end
	end
end

local function tag_bottom_bar_toggle_fn(screen)
	if not screen then
		return
	end
	-- One screen can have multiple selected tags
	local tags = screen.selected_tags
	for _, t in pairs(tags) do
		local clients = t:clients()
		local taskbarItems = 0
		for _, c in pairs(clients) do
			-- refresh width
			if c.maximized_horizontal then
				c.maximized_horizontal = false
				c.maximized_horizontal = true
			end
			-- refresh height
			if c.maximized_vertical then
				c.maximized_vertical = false
				c.maximized_vertical = true
			end
			-- check for taskbar items
			if not c.skip_taskbar then
				taskbarItems = taskbarItems + 1
			end
		end
		if screen.mybotwibox then
			screen.mybotwibox.visible = taskbarItems > 1
		end
	end
end
-- }}}

-- {{{ Wibox
local markup = lain.util.markup
local separators = lain.util.separators

-- Textclock
-- wibox.widget.textclock is ok but does not respect LC_DATE and LC_TIME.
-- If you locale is the same as LC_DATE and LC_TIME, you will so no difference to the default widget.
-- Caused by a call to g_locale_from_utf8.
local clockicon = wibox.widget.imagebox(beautiful.widget_clock)
local clock = wibox.widget.textbox()
local function clock_refresh()
	awful.spawn.easy_async(
		{"sh", "-c", "date +' %a %d %b %R '"},
		function(out)
			clock.text = out
		end
	)
end
clock_refresh()
gears.timer {
	timeout   = 60,
	autostart = true,
	callback  = clock_refresh
}

-- Calendar
lain.widget.calendar(
	{
		cal = "/usr/bin/ncal -h -w -3",
		followtag = true,
		attach_to = { clock },
		notification_preset = {
			font = beautiful.font_name,
			fg   = beautiful.fg_normal,
			bg   = beautiful.bg_normal
		}
	}
)

-- MEM
local memicon = wibox.widget.imagebox(beautiful.widget_mem)
local mem = lain.widget.mem(
	{
		settings = function()
			widget:set_text(" " .. string.format("%5d", mem_now.used) .. "MB ")
		end
	}
)

-- CPU
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpu = lain.widget.cpu(
	{
		settings = function()
			widget:set_text(" " .. string.format("%3d", cpu_now.usage) .. "% ")
		end
	}
)

-- / fs
local fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
local fsroot = lain.widget.fs(
	{
		followtag = true,
		options  = "--exclude-type=tmpfs",
		notification_preset = { 
			font = beautiful.font_name,
			fg   = beautiful.fg_normal,
			bg   = beautiful.bg_normal
		},
		settings = function()
			widget:set_text(" " .. string.format("%3d", fs_now.used) .. "% ")
		end
	}
)

-- Battery
local baticon = wibox.widget.imagebox(beautiful.bat)
local bat = battery(
	{
		settings = function()
			if bat_now.status == "Discharging" then
				if bat_now.perc <= 5 then
					baticon:set_image(beautiful.bat_no)
				elseif bat_now.perc <= 15 then
					baticon:set_image(beautiful.bat_low)	
				else
					baticon:set_image(beautiful.bat)
				end
				widget:set_markup(string.format("%3d", math.ceil(bat_now.perc)) .. "% ")
				return
			end
			-- We must be on AC
			baticon:set_image(beautiful.ac)
			widget:set_markup(bat_now.time .. " ")
		end
	}
)

-- ALSA volume
local volicon = wibox.widget.imagebox(beautiful.widget_vol)
local volume = lain.widget.alsa(
	{
		settings = function()
			if volume_now.status == "off" then
				volicon:set_image(beautiful.widget_vol_mute)
			elseif tonumber(volume_now.level) == 0 then
				volicon:set_image(beautiful.widget_vol_no)
			elseif tonumber(volume_now.level) <= 50 then
				volicon:set_image(beautiful.widget_vol_low)
			else
				volicon:set_image(beautiful.widget_vol)
			end

			widget:set_text(" " .. string.format("%3d", volume_now.level) .. "% ")
		end
	}
)

-- Net
local neticon = wibox.widget.imagebox(beautiful.widget_net)
neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.spawn_with_shell(iptraf) end)))
local net = lain.widget.net(
	{
		settings = function()
			widget:set_markup(
				markup("#7AC82E", string.format("%4d", math.ceil(net_now.received)))
				.. " " ..
				markup("#46A8C3", string.format("%4d", math.ceil(net_now.sent)))
				.. " "
			)
		end
	}
)

-- Separators
local spr = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
	if client.focus then
		client.focus:toggle_tag(t)
	end
end)
)

local tasklist_buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, client_menu_toggle_fn())
)

-- awfs
awfs.callback = function(screen, ontop)
	screen.mytopwibox.ontop = ontop
	screen.mybotwibox.ontop = ontop
end

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Tags
	awful.tag(tagnames, s, awful.layout.layouts)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

	-- Create a tasklist widget
	s.myfocusedtask = awful.widget.tasklist(s,
					 function(c, screen)
						 if awful.widget.tasklist.filter.currenttags(c, screen) then
							 if #awful.client.visible(screen) == 1 and not c.minimized then
								 return true
							 end
							 if awful.widget.tasklist.filter.minimizedcurrenttags(c, screen) then
								 return false
							 end
							 return awful.widget.tasklist.filter.focused(c, screen)
						 end
						 return false
					 end, tasklist_buttons)
	s.mytasklist = awful.widget.tasklist(s,
					 function (c, screen)
						 return not awful.widget.tasklist.filter.focused(c, screen) and awful.widget.tasklist.filter.currenttags(c, screen) and not c.skip_taskbar
					 end, tasklist_buttons)

	-- Create the top wibox
	s.mytopwibox = awful.wibar({ position = "top", ontop = true, screen = s })

	-- Create the bottom wibox
	s.mybotwibox = awful.wibar({ position = "bottom", ontop = true, visible = false, screen = s })

	-- Add widgets to the wibox
	s.mytopwibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			spr,
			s.mytaglist,
			s.mypromptbox,
			spr,
		},
		s.myfocusedtask, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			spr,
			arrl_ld,
			wibox.container.background(volicon, beautiful.bg_focus),
			wibox.container.background(volume.widget, beautiful.bg_focus),
			arrl_dl,
			fsicon,
			fsroot.widget,
			arrl_ld,
			wibox.container.background(memicon, beautiful.bg_focus),
			wibox.container.background(mem.widget, beautiful.bg_focus),
			arrl_dl,
			cpuicon,
			cpu.widget,
			arrl_ld,
			wibox.container.background(baticon, beautiful.bg_focus),
			wibox.container.background(bat.widget, beautiful.bg_focus),
			arrl_dl,
			neticon,
			net.widget,
			arrl_ld,
			wibox.container.background(clockicon, beautiful.bg_focus),
			wibox.container.background(clock, beautiful.bg_focus),
		},
	}

	-- Add widgets to the wibox
	s.mybotwibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			spr,
			arrl_ld,
			wibox.container.background(s.mylayoutbox, beautiful.bg_focus),
		},
	}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	-- ###
	-- Screenshots
	-- ###
	awful.key({                    }, "Print",
	   function()
		   awful.spawn("xfce4-screenshooter -o gimp", false)
	   end,
	   {description = "take a screenshot", group = "screenshot"}),
	awful.key({ altkey,            }, "Print",
	   function()
		   awful.spawn("xfce4-screenshooter -o gimp -w", false)
	   end,
	   {description = "take a screenshot of a window", group = "screenshot"}),
	awful.key({ "Shift",           }, "Print",
	   function()
		   awful.spawn("xfce4-screenshooter -o gimp -r", false)
	   end,
	   {description = "take a screenshot of an area", group = "screenshot"}),
	awful.key({ "Control",         }, "Print",
	   function()
		   awful.spawn("xfce4-screenshooter -c", false)
	   end,
	   {description = "copy a screenshot to the clipboard", group = "screenshot"}),
	awful.key({ "Control", altkey  }, "Print",
	   function()
		   awful.spawn("xfce4-screenshooter -c -w", false)
	   end,
	   {description = "copy a screenshot of a window to the clipboard", group = "screenshot"}),
	awful.key({ "Shift", "Control" }, "Print",
	   function()
		   awful.spawn("xfce4-screenshooter -c -r", false)
	   end,
	   {description = "copy a screenshot of an area to the clipboard", group = "screenshot"}),
	-- ###
	-- Layout manipulation
	-- ###
	awful.key({ modkey, "Shift"   }, "j",
	   function()
		   awful.client.swap.byidx(1)
	   end,
	   {description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift"   }, "k",
	   function()
		   awful.client.swap.byidx(-1)
	   end,
	   {description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey, "Control" }, "j",
	   function()
		   awful.screen.focus_relative(1)
	   end,
	   {description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" }, "k",
	   function()
		   awful.screen.focus_relative(-1)
	   end,
	   {description = "focus the previous screen", group = "screen"}),
	-- ###
	-- Cycle Layout
	-- ###
	awful.key({ modkey,           }, "space",
	   function()
		   awful.layout.inc( 1, mouse.screen)
	   end,
	   {description = "next layout", group = "tag"}),
	awful.key({ modkey, "Shift"   }, "space",
	   function()
		   awful.layout.inc(-1, mouse.screen)
	   end,
	   {description = "previous layout", group = "tag"}),
	-- ###
	-- Cycle Tag
	-- ###
	awful.key({ modkey,           }, "Tab",
	   function()
		   awful.tag.viewnext(mouse.screen)
	   end,
	   {description = "next tag", group = "tag"}),
	awful.key({ modkey, "Shift"   }, "Tab",
	   function()
		   awful.tag.viewprev(mouse.screen)
	   end,
	   {description = "previous tag", group = "tag"}),
	-- ###
	-- Cycle Client
	-- ###
	awful.key({ altkey,           }, "Tab",
	   function()
		   switcher.switch( 1, altkey, "Alt_L", "Shift", "Tab")
	   end,
	   {description = "next client", group = "client"}),
	awful.key({ altkey, "Shift"   }, "Tab",
	   function()
		   switcher.switch(-1, altkey, "Alt_L", "Shift", "Tab")
	   end,
	   {description = "previous client", group = "client"}),
	-- ###
	-- Dynamic tagging
	-- ###
	awful.key({ modkey, "Shift" }, "n",
	   function()
		   lain.util.add_tag()
	   end,
	   {description = "add tag", group = "tag"}),
	awful.key({ modkey, "Shift" }, "r",
	   function()
		   lain.util.rename_tag()
	   end,
	   {description = "rename tag", group = "tag"}),
	awful.key({ modkey, "Shift" }, "Left",
	   function()
		   lain.util.move_tag(1)
	   end,
	   {description = "move to next tag", group = "tag"}),
	awful.key({ modkey, "Shift" }, "Right",
	   function()
		   lain.util.move_tag(-1)
	   end,
	   {description = "move to previous tag", group = "tag"}),
	awful.key({ modkey, "Shift" }, "d",
	   function() 
		   lain.util.delete_tag() 
	   end,
	   {description = "delete tag", group = "tag"}),
	-- ###
	-- Volume control
	-- ###
	awful.key({ }, "#123",
	   function()
		   os.execute(string.format("amixer set %s 1%%+", volume.channel))
		   volume.update()
	   end,
	   {description = "increase volume", group = "volume"}),
	awful.key({ }, "#122",
	   function()
		   os.execute(string.format("amixer set %s 1%%-", volume.channel))
		   volume.update()
	   end,
	   {description = "decrease volume", group = "volume"}),
	awful.key({ }, "#121",
	   function()
		   os.execute(string.format("amixer set %s toggle", volume.togglechannel or volume.channel))
		   volume.update()
	   end,
	   {description = "toggle volume", group = "volume"}),
	awful.key({ }, "#198",
	   function()
		   os.execute("amixer set Capture toggle")
		   volume.update()
	   end,
	   {description = "toggle capture", group = "volume"}),
	-- ###
	-- Copy primary to clipboard
	-- ###
	awful.key({ modkey }, "c",
	   function()
		   os.execute("xsel -p -o | xsel -i -b")
	   end,
	   {description = "copy primary to clipboard", group = "awesome"}),
	-- ###
	-- Standard program
	-- ###
	awful.key({ modkey, "Control" }, "r",
	   awesome.restart,
	   {description = "reload awesome", group = "awesome"}),
	awful.key({ modkey,           }, "Return",
	   function()
		   awful.spawn(terminal)
	   end,
	   {description = "open a terminal", group = "launcher"}),
	-- ###
	-- Lock screen
	-- ###
	awful.key({ modkey }, "l",
	   function()
		   os.execute("sync && xautolock -locknow")
	   end,
	   {description = "lock screen", group = "awesome"}),
	-- ###
	-- Default prompt
	-- ###
	awful.key({ modkey }, "r",
	   function()
		   menubar.show()
	   end,
	   {description = "run prompt", group = "launcher"})
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",
	   function(c)
		   c.fullscreen = not c.fullscreen
		   c:raise()
	   end,
	   {description = "toggle fullscreen", group = "client"}),
	awful.key({ modkey, "Shift"   }, "c",
	   function(c)
		   c:kill()
	   end,
	   {description = "close", group = "client"}),
	awful.key({ modkey, "Control"   }, "space",
	   function(c)
		   c.floating = not c.floating
	   end,
	   {description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control" }, "Return",
	   function(c)
		   c:swap(awful.client.getmaster())
	   end,
	   {description = "move to master", group = "client"}),
	awful.key({ modkey,           }, "o",
	   function(c)
		   -- Enable move for maximized clients
		   local max_h = c.maximized_horizontal
		   local max_v = c.maximized_vertical
		   c.maximized_horizontal = false
		   c.maximized_vertical = false
		   c:move_to_screen()
		   c.maximized_horizontal = max_h
		   c.maximized_vertical = max_v
	   end,
	   {description = "move to next screen", group = "client"}),
	awful.key({ modkey,           }, "Down",
	   function(c)
		   -- The client currently has the input focus, so it cannot be
		   -- minimized, since minimized clients can't have the focus.
		   c.minimized = true
	   end,
	   {description = "minimize", group = "client"}),
	awful.key({ modkey,           }, "Up",
	   function(c)
		   c:emit_signal("maximize")
	   end,
	   {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
				    -- View tag only.
				    awful.key({ modkey }, "#" .. i + 9,
		  function ()
			  local screen = awful.screen.focused()
			  local tag = screen.tags[i]
			  if tag then
				  tag:view_only()
			  end
		  end,
		  {description = "view tag #"..i, group = "tag"}),
				    -- Toggle tag display.
				    awful.key({ modkey, "Control" }, "#" .. i + 9,
		  function ()
			  local screen = awful.screen.focused()
			  local tag = screen.tags[i]
			  if tag then
				  awful.tag.viewtoggle(tag)
			  end
		  end,
		  {description = "toggle tag #" .. i, group = "tag"}),
				    -- Move client to tag.
				    awful.key({ modkey, "Shift" }, "#" .. i + 9,
		  function ()
			  if client.focus then
				  local tag = client.focus.screen.tags[i]
				  if tag then
					  client.focus:move_to_tag(tag)
				  end
			  end
		  end,
		  {description = "move focused client to tag #"..i, group = "tag"}),
				    -- Toggle tag on focused client.
				    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
		  function ()
			  if client.focus then
				  local tag = client.focus.screen.tags[i]
				  if tag then
					  client.focus:toggle_tag(tag)
				  end
			  end
		  end,
		  {description = "toggle focused client on tag #" .. i, group = "tag"})
			    )
end

clientbuttons = awful.util.table.join(
	awful.button({        }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {
		},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			keys = clientkeys,
			buttons = clientbuttons,
			raise = true,
			screen = awful.screen.preferred,
			focus = awful.client.focus.filter,
			placement = awful.placement.centered
		}
	},
	{
		-- IntelliJ has dialogs, which shall not get focus, e.g. open type or open resource.
		-- These are Java Dialogs, which are not X11 Dialog Types.
		rule_any = {
			instance = { "sun-awt-X11-XWindowPeer", "sun-awt-X11-XDialogPeer", "keybase" }
		},
		properties = {
			placement = awful.placement.under_mouse+awful.placement.no_offscreen
		}
	},
	{
		rule_any = {
			type = { "notification" },
			name = { "Microsoft Teams Notification", "Slack | mini panel" },
		},
		properties = {
			titlebars_enabled = false,
			floating = true,
			focus = false,
			draw_backdrop = false,
			skip_decoration = true,
			skip_taskbar = true,
			ontop = true,
			sticky = true,
			size_hints_honor = true,
			maximized_horizontal = false,
			maximized_vertical = false,
			placement = awful.placement.top_right,
			height = 10
		}
	},
}
-- }}}

-- {{{ Signals
-- Toggle the bottom bar if client is tagged
tag.connect_signal("tagged", function(t)
	tag_bottom_bar_toggle_fn(t.screen)
end)
-- Toggle the bottom bar if client is untagged
tag.connect_signal("untagged", function(t)
	tag_bottom_bar_toggle_fn(t.screen)
end)
-- Toggle the bottom bar if selected tag changes
tag.connect_signal("property::selected", function(t)
	tag_bottom_bar_toggle_fn(t.screen)
end)

-- Prevent clients from being unreachable after screen count changes
client.connect_signal("property::screen", function(c)
	awful.placement.no_offscreen(c)
end)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Prevent clients from being unreachable after screen count changes
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse. Keep focus on Java dialogs.
client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

-- No border for maximized clients
client.connect_signal("property::maximized", function(c)
	if c.maximized then
		c.border_width = 0
	else
		c.border_width = beautiful.border_width
	end
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

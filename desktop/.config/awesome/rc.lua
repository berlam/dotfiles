-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
local alttab    = require("alttab")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
		rreset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true

		naughty.notify({
		 preset = naughty.config.presets.critical,
		 title = "Oops, an error happened!",
		 text = err
	 })
		in_error = false
	end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
	findme = cmd
	firstspace = cmd:find(" ")
	if firstspace then
		findme = cmd:sub(0, firstspace-1)
	end
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end
-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

-- alttab
function hex2rgba(hex)
	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), 1
end
alttab.settings.preview_box_bg = beautiful.border_focus .. "AA"
alttab.settings.preview_box_border = beautiful.bg_focus .. "00"
alttab.settings.preview_box_delay = 0
alttab.settings.preview_box_title_font = beautiful.font_name
alttab.settings.preview_box_title_font_size_factor = 1
alttab.settings.preview_box_title_color = {hex2rgba(beautiful.fg_focus)}

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "sakura"
editor     = os.getenv("EDITOR") or "nano" or "vi"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "google-chrome"
browser2   = "iron"
gui_editor = "gvim"
graphics   = "gimp"
mail       = terminal .. " -e mutt "
iptraf     = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr   = terminal .. " -g 130x34-320+16 -e ncmpcpp "

local layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
}
-- }}}

-- {{{ Tags
tags = {
	names = { "", "!#" },
	layout = { layouts[1], awful.layout.suit.tile }
}

for s = 1, screen.count() do
	tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end
-- }}}

-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
			    theme = { height = 16, width = 130 }})
-- }}}

-- {{{ Wibox
markup = lain.util.markup
separators = lain.util.separators

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(" %a %d %b  %H:%M")

mytextclock = lain.widgets.abase({
				 timeout  = 60,
				 cmd      = "date +'%a %d %b %R'",
				 settings = function()
					 widget:set_text(" " .. output)
				 end
			 })

-- calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
			     settings = function()
				     widget:set_text(" " .. string.format("%5d", mem_now.used) .. "MB ")
			     end
		     })

-- CPU
cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
cpubar = awful.widget.progressbar()
cpubar:set_color(beautiful.fg_normal)
cpubar:set_width(55)
cpubar:set_ticks(true)
cpubar:set_ticks_size(6)
cpubar:set_background_color(beautiful.bg_normal)
cpumargin = wibox.layout.margin(cpubar, 2, 7)
cpumargin:set_top(6)
cpumargin:set_bottom(6)
cpuupd = lain.widgets.cpu({
			  settings = function()
				  cpu_usage = tonumber(cpu_now.usage)
				  if cpu_usage >= 98 then
					  cpubar:set_color(red)
				  elseif cpu_usage > 50 then
					  cpubar:set_color(beautiful.fg_normal)
				  elseif cpu_usage > 15 then
					  cpubar:set_color(beautiful.fg_normal)
				  else
					  cpubar:set_color(green)
				  end
				  cpubar:set_value(cpu_usage / 100)
			  end
		  })
cpuwidget = wibox.widget.background(cpumargin)
cpuwidget:set_bgimage(beautiful.widget_bg)

-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
fswidget = lain.widgets.fs({
			   settings  = function()
				   widget:set_text(" " .. string.format("%3d", fs_now.used) .. "% ")
			   end
		   })

-- Battery
baticon = wibox.widget.imagebox(beautiful.bat)
batbar = awful.widget.progressbar()
batbar:set_color(beautiful.fg_normal)
batbar:set_width(55)
batbar:set_ticks(true)
batbar:set_ticks_size(6)
batbar:set_background_color(beautiful.bg_normal)
batmargin = wibox.layout.margin(batbar, 2, 7)
batmargin:set_top(6)
batmargin:set_bottom(6)
batupd = lain.widgets.bat({
			  settings = function()
				  if bat_now.perc == "N/A" or bat_now.status == "Not present" then
					  bat_perc = 100
					  baticon:set_image(beautiful.ac)
				  elseif bat_now.status == "Charging" then
					  bat_perc = tonumber(bat_now.perc)
					  baticon:set_image(beautiful.ac)

					  if bat_perc >= 98 then
						  batbar:set_color(green)
					  elseif bat_perc > 50 then
						  batbar:set_color(beautiful.fg_normal)
					  elseif bat_perc > 15 then
						  batbar:set_color(beautiful.fg_normal)
					  else
						  batbar:set_color(red)
					  end
				  else
					  bat_perc = tonumber(bat_now.perc)

					  if bat_perc >= 98 then
						  batbar:set_color(green)
					  elseif bat_perc > 50 then
						  batbar:set_color(beautiful.fg_normal)
						  baticon:set_image(beautiful.bat)
					  elseif bat_perc > 15 then
						  batbar:set_color(beautiful.fg_normal)
						  baticon:set_image(beautiful.bat_low)
					  else
						  batbar:set_color(red)
						  baticon:set_image(beautiful.bat_no)
					  end
				  end
				  batbar:set_value(bat_perc / 100)
			  end
		  })
batwidget = wibox.widget.background(batmargin)
batwidget:set_bgimage(beautiful.widget_bg)

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
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
			 })

-- Net
neticon = wibox.widget.imagebox(beautiful.widget_net)
neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
netwidget = lain.widgets.net({
			     settings = function()
				     widget:set_markup(
					     markup("#7AC82E", string.format("%4d", net_now.received))
					     .. " " ..
					     markup("#46A8C3", string.format("%4d", net_now.sent))
					     .. " "
				     )
			     end
		     })

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)

-- Create a wibox for each screen and add it
mytopwibox = {}
mybotwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
myfocusedtask = {}
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function ()
	if instance then
		instance:hide()
		instance = nil
	else
		instance = awful.menu.clients({ width=250 })
	end
end),
	awful.button({ }, 4, function ()
awful.client.focus.byidx(1)
if client.focus then client.focus:raise() end
end),
	awful.button({ }, 5, function ()
awful.client.focus.byidx(-1)
if client.focus then client.focus:raise() end
end))

-- helper function to refresh maximized clients when wibox (dis)appears
local function refreshScreen (screen, visible, wibox)
	local clients = awful.client.visible(screen)
	if #clients > 1 == visible then
		wibox[screen].visible = visible
	end
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
	end
end


for s = 1, screen.count() do

	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()

	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	myfocusedtask[s] = awful.widget.tasklist(s,
					  function(c, screen)
						  local clients = awful.client.visible(screen)
						  return awful.widget.tasklist.filter.focused(c, screen) or (#clients == 1 and awful.widget.tasklist.filter.currenttags(c, screen)) 
					  end, mytasklist.buttons)
	mytasklist[s] = awful.widget.tasklist(s, 
					  function (c, screen)
						  return not awful.widget.tasklist.filter.focused(c, screen) and awful.widget.tasklist.filter.currenttags(c, screen)
					  end,
					  mytasklist.buttons)

	-- Create the top wibox
	mytopwibox[s] = awful.wibox({ position = "top", ontop = true, screen = s, height = 18 })

	-- Create the bottom wibox
	mybotwibox[s] = awful.wibox({ position = "bottom", ontop = true, screen = s, height = 18 })
	mybotwibox[s].visible = false

	bottom_right_layout = wibox.layout.align.horizontal()
	bottom_right_layout:set_middle(mytasklist[s])
	bottom_right_layout:set_right(mylayoutbox[s])
	mybotwibox[s]:set_widget(bottom_right_layout)

	-- Widgets that are aligned to the upper left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(spr)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])
	left_layout:add(spr)

	-- Widgets that are aligned to the upper right
	local right_layout_toggle = true
	local function right_layout_add (...)
		local arg = {...}
		if right_layout_toggle then
			right_layout:add(arrl_ld)
			for i, n in pairs(arg) do
				right_layout:add(wibox.widget.background(n ,beautiful.bg_focus))
			end
		else
			right_layout:add(arrl_dl)
			for i, n in pairs(arg) do
				right_layout:add(n)
			end
		end
		right_layout_toggle = not right_layout_toggle
	end

	right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then right_layout:add(wibox.widget.systray()) end
	right_layout:add(spr)
	right_layout:add(arrl)
	right_layout_add(volicon, volumewidget)
	right_layout_add(fsicon, fswidget)
	right_layout_add(memicon, memwidget)
	right_layout_add(cpuicon, cpuwidget)
	right_layout_add(baticon, batwidget)
	right_layout_add(neticon, netwidget)
	right_layout_add(mytextclock, spr)

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(myfocusedtask[s])
	layout:set_right(right_layout)
	mytopwibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
									))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	-- Take a screenshot
	awful.key({                    }, "Print", function() awful.util.spawn("xfce4-screenshooter -o gimp", false) end),
	-- Take a screenshot of a window
	awful.key({ altkey,            }, "Print", function() awful.util.spawn("xfce4-screenshooter -o gimp -w", false) end),
	-- Take a screenshot of an area
	awful.key({ "Shift",           }, "Print", function() awful.util.spawn("xfce4-screenshooter -o gimp -r", false) end),
	-- Copy a screenshot to clipboard 
	awful.key({ "Control",         }, "Print", function() awful.util.spawn("xfce4-screenshooter -c", false) end),
	-- Copy a screenshot of a window to clipboard
	awful.key({ "Control", altkey  }, "Print", function() awful.util.spawn("xfce4-screenshooter -c -w", false) end),
	-- Copy a screenshot of an area to clipboard
	awful.key({ "Shift", "Control" }, "Print", function() awful.util.spawn("xfce4-screenshooter -c -r", false) end),

	-- Tag browsing
	awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
	awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
	awful.key({ modkey }, "Escape", awful.tag.history.restore),

	-- Non-empty tag browsing
	--[[
	awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
	awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),
	]]
	-- Default client focus
	--[[
	awful.key({ altkey }, "k",
	   function ()
		   awful.client.focus.byidx( 1)
		   if client.focus then client.focus:raise() end
	   end),
	awful.key({ altkey }, "j",
	   function ()
		   awful.client.focus.byidx(-1)
		   if client.focus then client.focus:raise() end
	   end),
	]]
	-- By direction client focus
	awful.key({ modkey }, "j",
	   function()
		   awful.client.focus.bydirection("down")
		   if client.focus then client.focus:raise() end
	   end),
	awful.key({ modkey }, "k",
	   function()
		   awful.client.focus.bydirection("up")
		   if client.focus then client.focus:raise() end
	   end),
	awful.key({ modkey }, "h",
	   function()
		   awful.client.focus.bydirection("left")
		   if client.focus then client.focus:raise() end
	   end),
	awful.key({ modkey }, "l",
	   function()
		   --[[
		   awful.client.focus.bydirection("right")
		   if client.focus then client.focus:raise() end
		   ]]
		   os.execute("dm-tool lock")
	   end),

	-- Show Menu
	awful.key({ modkey }, "w",
	   function ()
		   mymainmenu:show({ keygrabber = true })
	   end),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab",
	   function ()
		   awful.tag.viewnext(s)
	   end),
	awful.key({ modkey, "Shift"   }, "Tab",
	   function ()
		   awful.tag.viewprev(s)
	   end),
	awful.key({ altkey,           }, "Tab",
	   function ()
		   --[[
		   awful.client.cycle(false)
		   awful.client.focus.byidx(0, awful.client.getmaster())
		   if client.focus then client.focus:raise() end
		   ]]
		   alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
	   end),
	awful.key({ altkey, "Shift"   }, "Tab",
	   function ()
		   --[[
		   awful.client.cycle(true)
		   awful.client.focus.byidx(0, awful.client.getmaster())
		   if client.focus then client.focus:raise() end
		   ]]
		   alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
	   end),
	--[[
	awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
	awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
	]]
	awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
	awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
	awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
	awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
	awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
	awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
	awful.key({ modkey, "Control" }, "n",      awful.client.restore),

	-- Standard program
	awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r",      awesome.restart),
	--awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

	-- Dropdown terminal
	awful.key({ modkey,	      }, "z",      function () drop(terminal) end),

	-- Widgets popups
	--[[
	awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
	awful.key({ altkey,           }, "h",      function () fswidget.show(7) end),
--]]
	-- ALSA volume control
	awful.key({ }, "#123",
	   function ()
		   os.execute(string.format("amixer set %s 1%%+", volumewidget.channel))
		   volumewidget.update()
	   end),
	awful.key({ }, "#122",
	   function ()
		   os.execute(string.format("amixer set %s 1%%-", volumewidget.channel))
		   volumewidget.update()
	   end),
	awful.key({ }, "#121",
	   function ()
		   os.execute(string.format("amixer set %s toggle", volumewidget.channel))
		   volumewidget.update()
	   end),
	--[[
	awful.key({ altkey, "Control" }, "m",
	   function ()
		   os.execute(string.format("amixer set %s 100%%", volumewidget.channel))
		   volumewidget.update()
	   end),

	-- MPD control
	awful.key({ altkey, "Control" }, "Up",
	   function ()
		   awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
		   mpdwidget.update()
	   end),
	awful.key({ altkey, "Control" }, "Down",
	   function ()
		   awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
		   mpdwidget.update()
	   end),
	awful.key({ altkey, "Control" }, "Left",
	   function ()
		   awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
		   mpdwidget.update()
	   end),
	awful.key({ altkey, "Control" }, "Right",
	   function ()
		   awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
		   mpdwidget.update()
	   end),
	]]
	-- Copy to clipboard
	awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

	-- User programs
	awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
	awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end),
	awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),
	awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

	-- Prompt
	awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
	awful.key({ modkey }, "x",
	   function ()
		   awful.prompt.run({ prompt = "Run Lua code: " },
		      mypromptbox[mouse.screen].widget,
		      awful.util.eval, nil,
		      awful.util.getdir("cache") .. "/history_eval")
	   end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      
	   function (c)
		   local screen = c.screen
		   awful.client.movetoscreen(c)
		   refreshScreen(screen, false, mybotwibox)
		   refreshScreen(c.screen, true, mybotwibox)
	   end),
	awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
	awful.key({ modkey,           }, "n",
	   function (c)
		   -- The client currently has the input focus, so it cannot be
		   -- minimized, since minimized clients can't have the focus.
		   c.minimized = true
	   end),
	awful.key({ modkey,           }, "Up",
	   function (c)
		   c.maximized_horizontal = not c.maximized_horizontal
		   c.maximized_vertical   = not c.maximized_vertical
	   end)
)

-- Bind all key numbers to tags.
-- be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
				    -- View tag only.
				    awful.key({ modkey }, "#" .. i + 9,
		  function ()
			  local screen = mouse.screen
			  local tag = awful.tag.gettags(screen)[i]
			  if tag then
				  awful.tag.viewonly(tag)
			  end
		  end),
				    -- Toggle tag.
				    awful.key({ modkey, "Control" }, "#" .. i + 9,
		  function ()
			  local screen = mouse.screen
			  local tag = awful.tag.gettags(screen)[i]
			  if tag then
				  awful.tag.viewtoggle(tag)
			  end
		  end),
				    -- Move client to tag.
				    awful.key({ modkey, "Shift" }, "#" .. i + 9,
		  function ()
			  if client.focus then
				  local tag = awful.tag.gettags(client.focus.screen)[i]
				  if tag then
					  awful.client.movetotag(tag)
				  end
			  end
		  end),
				    -- Toggle tag.
				    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
		  function ()
			  if client.focus then
				  local tag = awful.tag.gettags(client.focus.screen)[i]
				  if tag then
					  awful.client.toggletag(tag)
				  end
			  end
		  end))
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
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { }, properties = {
	border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus = awful.client.focus.filter,
	keys = clientkeys,
	buttons = clientbuttons,
	size_hints_honor = false,
} },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
	client.connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			-- Skip focusing the client if the mouse wasn't moved.
			if c ~= sloppyfocus_last.c then
				client.focus = c
				sloppyfocus_last.c = c
			end
		end
	end)

	-- floating windows should be opened in the center of the screen by default
	-- (and if this place is already taken, they should be opened somewhere else)
	if not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_overlap(c)
		awful.placement.no_offscreen(c)
		awful.placement.centered(n, nil)
	end
	-- show bottom bar when more than one client is on screen.
	refreshScreen(c.screen, true, mybotwibox)
end)

-- signal function to execute when a new client disappears.
client.connect_signal("unmanage", function(c)
	-- hide bottom bar when only one client is on screen.
	refreshScreen(c.screen, false, mybotwibox)
end)

-- No border for maximized clients
client.connect_signal("focus", function(c)
	if c.maximized_horizontal == true and c.maximized_vertical == true then
		c.border_color = beautiful.border_normal
	else
		c.border_color = beautiful.border_focus
	end
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
	local clients = awful.client.visible(s)
	local layout  = awful.layout.getname(awful.layout.get(s))

	if #clients > 0 then -- Fine grained borders and floaters control
		for _, c in pairs(clients) do -- Floaters always have borders
			if awful.client.floating.get(c) or layout == "floating" then
				c.border_width = beautiful.border_width

				-- No borders with only one visible client
			elseif #clients == 1 or layout == "max" then
				c.border_width = 0
			else
				c.border_width = beautiful.border_width
			end
		end
	end
end)
end
-- }}}

-- {{{ Remember client size when switching between floating and tiling.
floatgeoms = {}

tag.connect_signal("property::layout", function(t)
	for k, c in ipairs(t:clients()) do
		if ((awful.layout.get(mouse.screen) == awful.layout.suit.floating) or (awful.client.floating.get(c) == true)) then
			c:geometry(floatgeoms[c.window])
		end
	end
end)

client.connect_signal("unmanage", function(c) 
floatgeoms[c.window] = nil
end)

client.connect_signal("property::geometry", function(c)
if ((awful.layout.get(mouse.screen) == awful.layout.suit.floating) or (awful.client.floating.get(c) == true)) then
	floatgeoms[c.window] = c:geometry()
end
end)


client.connect_signal("manage", function(c)
if ((awful.layout.get(mouse.screen) == awful.layout.suit.floating) or (awful.client.floating.get(c) == true)) then
	floatgeoms[c.window] = c:geometry()
end
end)
-- }}}

-- {{{ Make fullscreen clients ontop
client.connect_signal("property::fullscreen", function(c)
	mytopwibox[c.screen].ontop = not c.fullscreen
	mybotwibox[c.screen].ontop = not c.fullscreen
	os.execute("xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -T")
end)

-- Autostart
run_once("cmst -m")
run_once("xfce4-power-manager")
run_once("compton")

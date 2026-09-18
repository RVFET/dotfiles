local var_mod = "SUPER"

-- ===== Application Launchers =====
hl.bind(var_mod .. " + A", hl.dsp.exec_cmd("yad --title=\"Empty\" --class=\"empty\" --no-buttons --width=400 --height=400"))
hl.bind(var_mod .. " + B", hl.dsp.exec_cmd([[fish -c 'bruno-start']]))
hl.bind(var_mod .. " + C", hl.dsp.exec_cmd("$BROWSER"))
hl.bind(var_mod .. " + E", hl.dsp.exec_cmd("$FILEMANAGER"))
hl.bind(var_mod .. " + I", hl.dsp.exec_cmd("dms ipc call settings toggle"))
hl.bind(var_mod .. " + S", hl.dsp.exec_cmd("geany"))
hl.bind(var_mod .. " + M", hl.dsp.exec_cmd("dms ipc call dash toggle media"))
hl.bind(var_mod .. " + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind(var_mod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(var_mod .. " + W", hl.dsp.exec_cmd("dms ipc call notepad toggle"))
hl.bind(var_mod .. " + Y", hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))

hl.bind(var_mod .. " + Return", hl.dsp.exec_cmd("$TERMINAL"))
hl.bind(var_mod .. " + SHIFT + Y", hl.dsp.exec_cmd("dms ipc call wallpaper next"))
hl.bind(var_mod .. " + Pause", hl.dsp.exec_cmd([[fish -c 'mullvad reconnect --wait; sleep 1; set -l s (mullvad status | tail -n1 | choose -f "location:\s+" 1); notify-send -a Mullvad -u low -i /usr/share/icons/hicolor/16x16/apps/mullvad-vpn.png  (echo $s | choose -f "\. " -o "\n" 0 1)']]))
hl.bind(var_mod .. " + ALT + A", hl.dsp.exec_cmd("pkill -f \"yad.*class.*empty\""))
hl.bind(var_mod .. " + INSERT", hl.dsp.exec_cmd("fish -c \"b64img\""))

hl.bind("F10", hl.dsp.exec_cmd([[pkill -x mpvpaper || mpvpaper ALL "$HOME/Pictures/Wallpapers/Videos/" --slideshow 600 -a FULL -p -o "--panscan=1"]]))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind("CTRL + ESCAPE", hl.dsp.exec_cmd("dms color pick --hex -a"))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd("dms ipc call processlist toggle"))
hl.bind("CTRL + SHIFT + Q", hl.dsp.exec_cmd("fish -c 'set win (hyprctl activewindow -j | jq -r \".class, .pid\"); yad --text=\"Force-kill $win?\" --button=\"Cancel:1\" --button=\"OK:0\" && kill -9 $win'"))


-- ===== SUPER + NUM N = Move to workspace N =====
local smw_ok, smw = pcall(require, "plugins.split-monitor-workspaces")
if smw_ok then
    smw.setup({
      workspace_count = 2,
      max_workspaces = { ["DP-1"] = 3 },
      enable_wrapping = true,
      enable_notifications = false,
    })

    for i = 1, 10 do
        local workspace_num = tostring(i)
        local key = tostring(i % 10)
        hl.bind(var_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace_num }))
        hl.bind(var_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace_num }))
    end

    hl.bind(var_mod .. " + TAB", smw.workspace("+1"))
end


-- ===== Cheat sheet =====
hl.bind(var_mod .. " + SHIFT + Slash", hl.dsp.exec_cmd("dms ipc call keybinds toggle hyprland"))
hl.bind(var_mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload && hyprpm reload && dms restart"))

-- ===== Security =====
hl.bind(var_mod .. " + L", hl.dsp.exec_cmd("dms ipc call lock lock"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("dms ipc call processlist toggle"))
hl.bind(var_mod .. " + X", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({
            action = "toggle",
            monitor = "DP-1"
        }))
        hl.dispatch(hl.dsp.dpms({
            action = "toggle",
            monitor = "DP-2"
        }))
    end, { timeout = 500, type = "oneshot" })
end)

-- Audio Controls
hl.bind(var_mod .. " + SHIFT + Space", hl.dsp.exec_cmd("playerctl play-pause"), {
    repeating = true,
    locked = true,
})
hl.bind(var_mod .. " + SHIFT + P", hl.dsp.exec_cmd("playerctl previous"), {
    repeating = true,
    locked = true,
})
hl.bind(var_mod .. " + SHIFT + N", hl.dsp.exec_cmd("playerctl next"), {
    repeating = true,
    locked = true,
})

-- Vol = 5%
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.5"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1.5"), {
    repeating = true,
    locked = true,
})

-- Control + Vol = 10%
hl.bind("CTRL + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+ -l 1.5"), {
    repeating = true,
    locked = true,
})
hl.bind("CTRL + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%- -l 1.5"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), {
    locked = true,
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), {
    locked = true,
})

-- ===== Brightness Controls =====
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("dms ipc call brightness increment 5 \"\""), {
    repeating = true,
    locked = true,
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5 \"\""), {
    repeating = true,
    locked = true,
})
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call brightness increment 1 \"\""), {
    repeating = true,
    locked = true,
})
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call brightness decrement 1 \"\""), {
    repeating = true,
    locked = true,
})

-- Focus/Move window to Monitor Left/Right
hl.bind(var_mod .. " + CTRL + right", hl.dsp.focus({ monitor = "+1" }))
hl.bind(var_mod .. " + CTRL + left", hl.dsp.focus({ monitor = "-1" }))
hl.bind(var_mod .. " + SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "-1" }))
hl.bind(var_mod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "+1" }))

-- Focus/Move window to Workspace Left/Right (Current Monitor)
hl.bind(var_mod .. " + CTRL + down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(var_mod .. " + CTRL + up", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(var_mod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(var_mod .. " + SHIFT + CTRL + up", hl.dsp.window.move({ workspace = "r-1" }))

-- Move Window Globally (Between Active Workspaces/Monitors)
hl.bind(var_mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(var_mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(var_mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(var_mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Focus Window L/R/U/D
hl.bind(var_mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(var_mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(var_mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(var_mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Center floating window
hl.bind(var_mod .. " + Z", hl.dsp.window.center())

-- Cycle Workspaces on Current Monitor (Mouse)
hl.bind(var_mod .. " + mouse_down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(var_mod .. " + mouse_up", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(var_mod .. " + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(var_mod .. " + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "r-1" }))

-- ===== Orientation and Fullscreen =====
hl.bind(var_mod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(var_mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(var_mod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(var_mod .. " + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(var_mod .. " + G", hl.dsp.group.toggle())
-- regular close
hl.bind(var_mod .. " + Q", hl.dsp.window.close())
-- politely ask to fuck off
hl.bind(var_mod .. " + SHIFT + Q", hl.dsp.window.signal({ signal = 15 }))
-- forcekill / sigkill / -9
hl.bind(var_mod .. " + CTRL + SHIFT + Q", hl.dsp.window.kill())

-- Drag to Move/Resize
hl.bind(var_mod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true,
    description = "Move window",
})
hl.bind(var_mod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true,
    description = "Resize window",
})

-- Drag to Move/Resize (Keys)
hl.bind(var_mod .. " + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), {
    description = "Expand window left",
})
hl.bind(var_mod .. " + code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), {
    description = "Shrink window left",
})

-- Manual Sizing
hl.bind(var_mod .. " + minus", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), {
    repeating = true,
})
hl.bind(var_mod .. " + equal", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), {
    repeating = true,
})

local resize_mult = 20
hl.bind(var_mod .. " + ALT + right", hl.dsp.window.resize({ x = 1*resize_mult, y = 0, relative = true }), {
    repeating = true,
})
hl.bind(var_mod .. " + ALT + left", hl.dsp.window.resize({ x = -1*resize_mult, y = 0, relative = true }), {
    repeating = true,
})
hl.bind(var_mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 1*resize_mult, relative = true }), {
    repeating = true,
})
hl.bind(var_mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -1*resize_mult, relative = true }), {
    repeating = true,
})

-- Global Zoom In
hl.bind(var_mod .. " + SHIFT + equal", hl.dsp.exec_cmd("hyprctl eval \"hl.config({ cursor = { zoom_factor = $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.3') }})\""), {
    repeating = true,
})

-- Global Zoom out
hl.bind(var_mod .. " + SHIFT + minus", hl.dsp.exec_cmd("hyprctl eval \"hl.config({ cursor = { zoom_factor = $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.8) | if . < 1 then 1 else . end') }})\""), {
    repeating = true,
})

-- Global Reset zoom
hl.bind(var_mod .. " + SHIFT + 0", hl.dsp.exec_cmd("hyprctl eval \"hl.config({ cursor = { zoom_factor = $(hyprctl getoption cursor:zoom_factor -j | jq '1.0') }})\""), {
    repeating = true,
})

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("fish -c \"dms screenshot -d ~/Pictures/Screenshots --stdout | satty -f -\""))
hl.bind(var_mod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty -f -"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("grim - | tee \"$HOME/Pictures/Screenshots/fullscreen-$(date +%F_%T).png\" | wl-copy"))

-- OCR
hl.bind(var_mod .. " + SHIFT + C", hl.dsp.exec_cmd("ocrr"))

-- Disable middle click to paste (sometimes fucks shit up)
hl.bind("mouse:274", hl.dsp.exec_cmd("wl-copy -pc"), {
    non_consuming = true,
})

-- Touchpad Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    scale = 1,
    action = "workspace",
})
hl.gesture({
    fingers = 3,
    direction = "vertical",
    scale = 2,
    action = "workspace",
})
hl.gesture({
    fingers = 3,
    direction = "down",
    mods = "ALT",
    action = "close",
})
hl.gesture({
    fingers = 3,
    direction = "up",
    mods = "SUPER",
    scale = 1.5,
    action = "fullscreen",
})
hl.gesture({
    fingers = 4,
    direction = "up",
    action = "float",
    scale = 1.5,
})
hl.gesture({
    fingers = 4,
    direction = "down",
    action = function()
        hl.exec_cmd("playerctl play-pause")
    end,
    scale = 1.5,
})
hl.gesture({
    fingers = 4,
    direction = "left",
    action = function()
        hl.exec_cmd("playerctl next")
    end,
    scale = 1.5,
})
hl.gesture({
    fingers = 4,
    direction = "right",
    action = function()
        hl.exec_cmd("playerctl previous")
    end,
    scale = 1.5,
})
hl.gesture({
    fingers = 2,
    direction = "pinch",
    action = "resize",
    scale = 2,
})

-- FASTER, SNAPPIER, LESS DISTRACTIONS AND NO EYE-CANDY
hl.bind("SUPER + F1", function ()
    local serious_mode = (hl.get_config("decoration.rounding") == 0)

    if serious_mode then
        hl.exec_cmd("killall hyprsunset")
        hl.exec_cmd("dms run")
        hl.exec_cmd("hyprctl reload")
        return
    end

    hl.exec_cmd("hyprsunset -t 5500")
    hl.exec_cmd("dms kill")
    hl.config({
        animations = {
            enabled = true,
        },
        general = {
            gaps_in = 0,
            gaps_out = 0,
            border_size = 0,
        },
        decoration = {
            rounding = 0,
            shadow = { enabled = false },
            active_opacity = 1,
            inactive_opacity = 1,
        }
    })

    hl.curve("superfast", { type = "bezier", points = { { 0.1, 1.0 }, { 0.1, 1.0 } } })
    local fast_animations = {
        { leaf = "windowsIn",   speed = 1, bezier = "superfast" },
        { leaf = "windowsOut",  speed = 1, bezier = "superfast" },
        { leaf = "workspaces",  speed = 2, bezier = "superfast" },
        { leaf = "windowsMove", speed = 1, bezier = "superfast" },
        { leaf = "fade",        speed = 1, bezier = "superfast" },
        { leaf = "border",      speed = 1, bezier = "superfast" },
    }

    for _, anim in ipairs(fast_animations) do
        anim.enabled = true
        hl.animation(anim)
    end

    hl.window_rule({
        match = { class = "^(?!.*ghostty.*).*$" },
        opaque = true,
        border_size = 0,
        rounding = 0,
        no_blur = true,
        no_shadow = true
    })
end)

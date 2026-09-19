-- ===== MODULES & PLUGINS =====
package.path = package.path .. ";./?.lua;./?/init.lua"

require("monitors")
require("bindings")
require("dms.colors")

-- ===== ENVIRONMENT VARIABLES =====
local env_vars = {
    FILEMANAGER                         = "nemo",
    TERMINAL                            = "ghostty",
    BROWSER                             = "zen-browser",
    EDITOR                              = "micro",
    ELECTRON_OZONE_PLATFORM_HINT        = "wayland",
    WEBKIT_DISABLE_COMPOSITING_MODE     = "1",
    GDK_SCALE                           = "1",
    GDK_DPI_SCALE                       = "1",
    GSK_RENDERER                        = "gl",
    QT_SCALE_FACTOR                     = "1",
    QT_AUTO_SCREEN_SCALE_FACTOR         = "1",
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
    QT_QPA_PLATFORM                     = "wayland",
    QT_QPA_PLATFORMTHEME                = "gtk3",
    QT_QPA_PLATFORMTHEME_QT6            = "gtk3",
    XDG_CURRENT_DESKTOP                 = "Hyprland",
    XDG_SESSION_DESKTOP                 = "Hyprland",
    MOZ_ENABLE_WAYLAND                  = "1",
    XDG_SESSION_TYPE                    = "wayland",
    LIBVA_DRIVER_NAME                   = "nvidia",
    NVD_BACKEND                         = "direct",
    MOZ_DISABLE_RDD_SANDBOX             = "1",
    GIT_PAGER                           = "delta",
}

for key, val in pairs(env_vars) do
    hl.env(key, val)
end

-- ===== STARTUP EXECUTION =====
hl.on("hyprland.start", function()
    local startup_cmds = {
        "dms run",
        "gnome-keyring-daemon --start --components=secrets",
        "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1",
        "dbus-update-activation-environment --systemd --all",
        "systemctl --user import-environment QT_QPA_PLATFORMTHEME",
    }
    for _, cmd in ipairs(startup_cmds) do
        hl.exec_cmd(cmd)
    end
end)

-- ===== SYSTEM & UI CONFIGURATION =====
hl.config({
    input = {
        sensitivity = 0,
        kb_layout = "us,az,ru",
        numlock_by_default = true,
        kb_options = "grp:win_space_toggle",
        accel_profile = "flat",
        follow_mouse = 1,
        touchpad = {
            disable_while_typing = false,
            natural_scroll = true,
            scroll_factor = 1,
        },
    },
    general = {
        layout = "dwindle",
        gaps_in = 6,
        gaps_out = 12,
        border_size = 1,
        col = {
            active_border = "rgba(4D3B3Aff)",
            inactive_border = "rgba(141413ff)",
        },
    },
    decoration = {
        rounding = 32,
        rounding_power = 2.0,
        active_opacity = 0.9,
        inactive_opacity = 0.75,
--         screen_shader = "~/.config/hypr/shaders/example.frag",
        blur = {
            enabled = true,
            size = 16,
            passes = 3,
            xray = true,
            noise = 0.25,
            contrast = 2,
            popups = true,
            vibrancy = 0.8,
            brightness = 0.2,
            ignore_opacity = true,
            vibrancy_darkness = 0.8,
            new_optimizations = true,
            popups_ignorealpha = 0.2,
        },
        shadow = {
            enabled = true,
            range = 50,
            render_power = 2,
            offset = "0 4",
            color = "rgba(00000070)",
        },
    },
    animations = {
        enabled = true,
    },
    misc = {
        vrr = false,
        render_unfocused_fps = 15,
        focus_on_activate = false,
        disable_autoreload = false,
        disable_hyprland_logo = true,
        key_press_enables_dpms = false,
        disable_splash_rendering = true,
    },
    dwindle = {
        preserve_split = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    cursor = {
        no_warps = false,
        enable_hyprcursor = true,
        no_hardware_cursors = 2,
    }
})

-- ===== PLUGIN CONFIGURATIONS =====

-- dynamic-cursors
if hl.plugin and hl.plugin.dynamic_cursors ~= nil then
    hl.config({
        plugin = {
            dynamic_cursors = {
                enabled = true,
                mode = "tilt",
                threshold = 2,
                tilt = {
                    limit = 5000,
                    activation = "negative_quadratic",
                    window = 100,
                    full = 60,
                },
                shake = {
                    enabled = true,
                    threshold = 6.0,
                    base = 2.0,
                    speed = 10.0,
                    influence = 5.0,
                    limit = 30.0,
                    timeout = 1000,
                    effects = true,
                    ipc = false,
                },
                hyprcursor = {
                    enabled = true,
                    nearest = 1,
                    resolution = 1,
                    fallback = "clientside",
                },
            },
        },
    })
end

-- ===== ANIMATIONS & CURVES =====
hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.1, 1.08 } } })
hl.curve("default",  { type = "bezier", points = { { 0.05, 0.90 }, { 0.1, 1.05 } } })

local animations = {
    { leaf = "fade",        speed = 2, bezier = "default" },
    { leaf = "border",      speed = 2, bezier = "default" },
    { leaf = "windowsIn",   speed = 2, bezier = "default" },
    { leaf = "windowsOut",  speed = 2, bezier = "default" },
    { leaf = "windowsMove", speed = 2, bezier = "default" },
    { leaf = "workspaces",  speed = 3, bezier = "overshot", style = "slidevert" },
}

for _, anim in ipairs(animations) do
    anim.enabled = true
    hl.animation(anim)
end

-- ===== LAYER RULES =====
local layer_rules = {
    {
        match = { namespace = "^(quickshell|dms:.*|com.danklinux.dms)$" },
        blur = true,
        blur_popups = true,
        ignore_alpha = 0.0,
        no_anim = true
    },
}

for _, rule in ipairs(layer_rules) do
    hl.layer_rule(rule)
end

-- ===== WINDOW RULES =====
local window_rules = {
    -- System utilities / Floating dialogs
    { match = { class = "^(org\\.gnome\\.)" }, border_size = 0 },
    { match = { class = "^(gnome-control-center|pavucontrol|nm-connection-editor)$" }, tile = true },
    { match = { class = "^(blueman-manager|steam|xdg-desktop-portal|org.freedesktop.impl.portal.desktop.kde|Waydroid)$" }, float = true },

    -- Media / Overlays
    { match = { class = "^reqable$" }, float = true, opacity = 0.9, border_size = 0, decorate = false },
    { match = { title = "^(Picture-in-Picture|satty)$" }, float = true, opaque = true, border_size = 0 },

    -- Opacity rules
    { match = { class = "^(dev.zed.Zed|code|codium|yaak-app)$" }, opacity = 0.9 },
    { match = { class = "^brave-browser$", fullscreen = 0 }, opacity = 0.9, float = true, size = { 1936, 1096 } },
    { match = { class = "zen", fullscreen = 0 }, render_unfocused = true, float = true, center = true, size = {1936, 1096 } },

    -- Floating apps with explicit sizing
    { match = { class = "^(oculante)$" }, float = true, size = { 1400, 900 } },
    { match = { class = "yad" }, float = true, border_size = 0, no_shadow = true },
    { match = { class = "^(nemo)$" }, float = true, opacity = 0.8, size = { 1500, 850 } },
    { match = { class = "^(geany)$" }, float = true, opacity = 0.9, size = { 1300, 760 } },
    { match = { title = ".*sowon.*" }, float = true, opacity = 0.9, size = { 1200, 380 } },
    { match = { class = "^(org.gnome.clocks)$" }, float = true, opacity = 0.9, size = { 750, 480 } },
    { match = { class = "^(com.danklinux.dms)$", title = "Settings" }, float = true, opacity = 0.9, size = { 880, 1000 } },
    { match = { class = ".*(tdesktop|telegram|it.belloworld.mercurygram).*" }, float = true, opacity = 0.9, size = { 1350, 810 } },
    { match = { class = "^(com.mitchellh.ghostty|Alacritty|org.gnome.Ptyxis)$" }, float = true, opacity = 0.95, size = { 1800, 900 } },

    -- Heavy rendering overrides
    { match = { class = "^(com.freerdp.client.*)$" }, fullscreen = 1, float = false, decorate = false },
    { match = { class = ".*.(exe|bottles|steam_proton)$" }, opaque = true, no_blur = true, decorate = false, no_shadow = true },
    { match = { initial_class = "^(steam|steam_proton|bottles)$" }, decorate = false, opaque = true, no_anim = true, no_blur = true },
}

for _, rule in ipairs(window_rules) do
    hl.window_rule(rule)
end

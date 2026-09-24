-- Run with Lua to check the real config's lid callbacks without a compositor.
local config = arg[1] or "hypr/.config/hypr/hyprland.lua"
local state = os.tmpname()
local real_getenv, real_rename, real_loadfile = os.getenv, os.rename, loadfile
local monitors, updates, events, pending = {}, {}, {}, nil

local host = { lid = { output = "eDP-1", switch = "Lid Switch", state = state } }
local host_path = "/fixture/hypr/host.lua"
os.getenv = function(name)
    if name == "HOME" then return "/fixture" end
    if name == "XDG_CONFIG_HOME" then return "/fixture" end
    if name == "HYPRLAND_INSTANCE_SIGNATURE" then return "fixture" end
    return real_getenv(name)
end
os.rename = function(from, to)
    if from == host_path and to == host_path then return true end
    return false, "missing fixture file", 2
end
loadfile = function(path, ...)
    if path == host_path then return function() return host end end
    return real_loadfile(path, ...)
end

local function dispatcher()
    return setmetatable({}, {
        __index = function() return dispatcher() end,
        __call = function() return function() end end,
    })
end
hl = setmetatable({ plugin = {}, dsp = dispatcher() }, {
    __index = function(_, name)
        if name == "monitor" then
            return function(value)
                if value.output == "eDP-1" and value.disabled ~= nil then
                    updates[#updates + 1] = value.disabled
                end
            end
        end
        if name == "on" then return function(event, callback) events[event] = callback end end
        if name == "get_monitors" then return function() return monitors end end
        if name == "timer" then
            return function(callback)
                pending = { callback = callback, enabled = true }
                function pending:is_enabled() return self.enabled end
                return pending
            end
        end
        return function() end
    end,
})

local function write_state(value)
    local file = assert(io.open(state, "w"))
    assert(file:write(value))
    assert(file:close())
end
local function tick()
    events["monitor.layout_changed"]()
    assert(pending, "lid update was not scheduled")
    local callback = pending.callback
    pending.enabled = false
    pending = nil
    callback()
end
local function expect(value, count)
    assert(#updates == count, "unexpected monitor update count: " .. #updates)
    assert(updates[#updates] == value, "unexpected panel state")
end

write_state("state: closed\n")
dofile(config)
assert(events["hyprland.start"] and events["config.reloaded"])
monitors = { { name = "eDP-1" }, { name = "DP-5", dpmsStatus = false } }
tick()
expect(true, 1) -- A sleeping external output still counts.
tick()
expect(true, 1) -- Repeated observations must not recursively update.
monitors = { { name = "eDP-1" }, { name = "FALLBACK" }, { name = "DP-5", is_mirror = true } }
tick()
expect(false, 2)
monitors = { { name = "eDP-1" } }
tick()
expect(false, 2)
monitors = { { name = "eDP-1" }, { name = "DP-5" } }
tick()
expect(true, 3)
write_state("state: open\n")
tick()
expect(false, 4)
write_state("unknown\n")
tick()
expect(false, 4)

assert(os.remove(state))
os.getenv, os.rename, loadfile = real_getenv, real_rename, real_loadfile
print("hyprland lid: synthetic monitor reconciliation passed")

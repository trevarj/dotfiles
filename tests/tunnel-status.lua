-- Run with Lua 5.1+; executes the real widget without reading host sysfs.
local pending, fixture, shown = {}, { names = { "lo" } }, {}
local rejected

noctalia = {
  setUpdateInterval = function() end,
  listDir = function(path)
    assert(path == "/sys/class/net")
    return fixture.names
  end,
  readFileAsync = function(path, callback)
    assert(path == "/sys/class/net/tun0/flags" or path == "/sys/class/net/tun0/carrier")
    if path:match("/([^/]+)$") == rejected then
      return false
    end
    table.insert(pending, { path = path, callback = callback })
    return true
  end,
}
barWidget = {
  setText = function(value) shown.text = value end,
  setGlyph = function(value) shown.glyph = value end,
  setGlyphColor = function(value) shown.color = value end,
  setTooltip = function(value) shown.tooltip = value end,
  setVisible = function(value) shown.visible = value end,
}

local function drain()
  while #pending > 0 do
    local request = table.remove(pending, 1)
    update()
    assert(#pending == 0, "overlapping poll while an async read is pending")
    local contents = fixture[request.path:match("/([^/]+)$")]
    request.callback(contents, contents == nil and "fixture read failure" or nil)
  end
end

local directory = arg[0]:match("^(.*[/])") or ""
dofile(directory .. "../noctalia/.config/noctalia/plugins/tunnel-status/widget.luau")
drain()
assert(shown.visible == false, "absent tun0 must be hidden")

local function check(flags, carrier, names, expected)
  fixture = { flags = flags, carrier = carrier, names = names }
  update()
  drain()
  assert(shown.text == "", "the indicator must remain icon-only")
  if expected == "hidden" then
    assert(shown.visible == false)
  else
    assert(shown.visible == true)
    assert(shown.glyph == (expected == "up" and "shield-check" or "shield-exclamation"))
  end
end

local present = { "lo", "tun0" }
check("0x0\n", nil, present, "hidden")
check("0x1002\n", nil, present, "hidden") -- down: carrier/EINVAL must not become an alert
check("0x1003\n", "1\n", present, "up")
check("0x1\n", "0\n", present, "hidden")
check("0xzz\n", "1\n", present, "alert")
check("", "1\n", present, "alert")
check("0x100000000\n", "1\n", present, "alert")
check("0x1\nextra", "1\n", present, "alert")
check("0x1\n", "2\n", present, "alert")
check("0x1\n", "", present, "alert")
check("0x1\n", "1\nextra", present, "alert")
check(nil, nil, present, "alert")
check("0x1\n", nil, present, "alert")
check(nil, nil, { "lo" }, "hidden")
check("0x1\n", nil, { "lo" }, "hidden") -- disappears between attribute reads
check(nil, nil, nil, "alert")
check(nil, nil, {}, "alert")
rejected = "flags"
check("0x1\n", "1\n", present, "alert")
rejected = "carrier"
check("0x1\n", "1\n", present, "alert")
rejected = nil
check("0x1\n", "1\n", present, "up") -- failed launch must not stall later polls
print("tunnel-status: live/hidden/error transitions, flags-first reads and single-flight polling passed")

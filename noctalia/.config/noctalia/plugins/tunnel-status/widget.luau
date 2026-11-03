--!nonstrict
local root = "/sys/class/net/tun0/"
local checking = false

local function finish(visible, alert, tooltip)
  checking = false
  barWidget.setText("")
  barWidget.setGlyph(alert and "shield-exclamation" or "shield-check")
  barWidget.setGlyphColor(alert and "error" or "on_surface")
  barWidget.setTooltip(tooltip)
  barWidget.setVisible(visible)
end

local function readFailed(attribute)
  -- Native async reads omit errno. Inspect names only on failure so a missing
  -- interface hides, but unreadable attributes/directories never imply down.
  local names = noctalia.listDir("/sys/class/net")
  if type(names) ~= "table" or #names == 0 then
    finish(true, true, "Tun0 status unavailable: cannot inspect network interfaces")
    return
  end
  for _, name in ipairs(names) do
    if name == "tun0" then
      finish(true, true, "Tun0 status unavailable: cannot read " .. attribute)
      return
    end
  end
  finish(false)
end

function update()
  if checking then
    return
  end
  checking = true
  local accepted = noctalia.readFileAsync(root .. "flags", function(contents)
    if contents == nil then
      readFailed("flags")
      return
    end
    local digits = contents:match("^0x(%x+)\n?$")
    if digits == nil or #digits > 8 then
      finish(true, true, "Tun0 status unavailable: malformed interface flags")
      return
    end
    if tonumber(digits, 16) % 2 == 0 then
      -- IFF_UP is clear; reading carrier here can return EINVAL on Linux.
      finish(false)
      return
    end
    local carrierAccepted = noctalia.readFileAsync(root .. "carrier", function(carrier)
      if carrier == nil then
        readFailed("carrier")
      elseif carrier:match("^1\n?$") then
        finish(true, false, "Tun0 up")
      elseif carrier:match("^0\n?$") then
        finish(false)
      else
        finish(true, true, "Tun0 status unavailable: malformed carrier")
      end
    end)
    if not carrierAccepted then
      finish(true, true, "Tun0 status unavailable: carrier read could not start")
    end
  end)
  if not accepted then
    finish(true, true, "Tun0 status unavailable: flags read could not start")
  end
end

noctalia.setUpdateInterval(1000)
finish(true, true, "Tun0 status: checking interface/carrier")
update()

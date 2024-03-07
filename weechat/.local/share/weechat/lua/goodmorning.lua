local wee = weechat

local me = "trev"
local server = "libera"
local chans = {
	"#trevsroom",
	"#systemcrafters",
}

local function init()
	if wee.register("goodmorning", "trevarj", "1.0", "GPL3", "", "", "") then
		wee.hook_signal(server .. ",irc_in2_privmsg", "GoodMorning", "")
	end

	local chan_set = {}
	for _, chan in ipairs(chans) do
		chan_set[chan] = true
	end
	chans = chan_set
end

function GoodMorning(_, _, signal_data)
	local msg = wee.info_get_hashtable("irc_message_parse", { message = signal_data })
	local chan = msg.channel
	if chans[chan] ~= nil then
		local buffer = wee.info_get("irc_buffer", string.format("%s,%s", server, chan))
		local message = string.lower(msg.text)

		if string.match(message, "good morning") then
			wee.command(buffer, string.format("good morning, %s", msg.nick))
		elseif string.match(message, me) and string.match(message, "%f[%a]hi%f[%A]") then
			wee.command(buffer, string.format("%s: hey", msg.nick))
		end
	end
end

init()

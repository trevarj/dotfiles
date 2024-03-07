local wee = weechat

local me = "trev"
local server = "libera"
local chans = {
	"#trevsroom",
	"#systemcrafters",
}

local greetings = { "good morning", "good day", "good evening", "hi", "hey", "howdy" }

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

local function contains_phrase(msg, phrase_list)
	for _, phrase in ipairs(phrase_list) do
		wee.print("", phrase)
		if string.match(msg, "%f[%a]" .. phrase .. "%f[%A]") then
			wee.print("", "matched" .. phrase)
			return true, phrase
		end
	end
	return false
end

function GoodMorning(_, _, signal_data)
	local msg = wee.info_get_hashtable("irc_message_parse", { message = signal_data })
	local chan = msg.channel
	if chans[chan] ~= nil then
		local buffer = wee.info_get("irc_buffer", string.format("%s,%s", server, chan))
		local message = string.lower(msg.text)

		local matched, phrase = contains_phrase(message, greetings)
		if matched then
			wee.command(buffer, string.format("%s: %s", msg.nick, phrase))
		end
	end
end

init()

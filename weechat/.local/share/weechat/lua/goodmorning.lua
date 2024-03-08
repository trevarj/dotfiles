local wee = weechat

local me = "trev"
local server = "libera"
local chans = {
	"#trevsroom",
	"#systemcrafters",
}

local greetings = { "good morning", "good day", "good evening" }
local personal_greetings = { "hello", "hi", "hey", "howdy", "yo", "hiya", "sup" }

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
		if string.match(msg, "%f[%a]" .. phrase .. "%f[%A]") then
			return phrase
		end
	end
end

function GoodMorning(_, _, signal_data)
	local msg = wee.info_get_hashtable("irc_message_parse", { message = signal_data })
	local chan = msg.channel
	if chans[chan] ~= nil then
		local buffer = wee.info_get("irc_buffer", string.format("%s,%s", server, chan))
		local message = string.lower(msg.text)
		local response

		if string.match(message, "trev") then
			local phrase = contains_phrase(message, personal_greetings)
			if phrase ~= nil then
				response = phrase
			end
		end

		local phrase = contains_phrase(message, greetings)
		if phrase ~= nil then
			response = phrase
		end

		if response ~= nil then
			wee.command(buffer, string.format("%s: %s", msg.nick, response))
		end
	end
end

init()

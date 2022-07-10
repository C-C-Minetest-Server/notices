local WP = minetest.get_worldpath()
local NOTICES_DATA_PATH = WP .. "/notices/"
local FORMSPEC_BASE = "size[12,8.25]button_exit[-0.05,7.8;2,1;exit;Close]textarea[0.25,0;12.1,9;news;;%s]"

local notices = {}

local function update_notices()
	local noticelistfile = io.open(NOTICES_DATA_PATH .. "list.txt","r")
	local noticelist = {}
	if noticelistfile then
		local noticelistdata = noticelistfile:read("*a")
		for s in noticelistdata:gmatch("[^\r\n]+") do
			table.insert(noticelist,s)
		end
	end
	for _,x in pairs(noticelist) do
		local noticefile = io.open(NOTICES_DATA_PATH .. x .. ".txt")
		local noticedata = "Listed, but file not found."
		if noticefile then
			noticedata = noticefile:read("*a")
		end
		notices[x] = noticedata
	end
end

local function get_formspec(notice_name)
	local disp_text = notices[notice_name] or "Notice not found."
	disp_text = disp_text .. "\n\n------------------------"
	disp_text = disp_text .. ("\nYou are currently viewing the note \"%s\"."):format(notice_name)
	disp_text = disp_text .. "\nAvaliable Notes:"
	for x,_ in pairs(notices) do
		disp_text = disp_text .. " " .. x
	end
	disp_text = disp_text .. "\nAccess them with /notice <name>!"
	return FORMSPEC_BASE:format(disp_text)
end

minetest.register_privilege("news_bypass",{
	description = "Skip the notes.",
	give_to_singleplayer = false,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if not minetest.get_player_privs(name).news_bypass then
		minetest.show_formspec(name, "notices:notices_init", get_formspec("init"))
	end
end)

minetest.register_chatcommand("notice", {
	description = "Display notes",
	param = "[<Note ID>]",
	func = function(name,param)
		if param == "" then param = "init" end
		minetest.show_formspec(name, "notices:notices_" .. param, get_formspec(param))
		return true
	end
})

minetest.register_chatcommand("notice_reload", {
	description = "Reload notes",
	privs = {server = true},
	func = function(name,param)
		update_notices()
		return true, "Notices updated."
	end
})

update_notices()


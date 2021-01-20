love.filesystem.setRequirePath("?.lua;?/init.lua;lib/?.lua;lib/?/init.lua;lib/?/?.lua")
require "irc"
require("color")

local channel = "bot_ioodyme"
local oauth = ""


function love.load(arg)
	s = irc.new{
		nick = "spectrenoir06_bot"
	}

	s:hook("OnChat",
		function(user, channel, message)
			print(("[%s] %s: %s"):format(channel, user.nick, message))
		end
	)
		
	s:connect({
		host = "irc.chat.twitch.tv",
		password = "oauth:"..oauth,
		-- secure = true,
	}, 6667)
	print("connect")


	s:join("#"..channel)
	s:think()

	s:sendChat("#"..channel, "bonsoir @"..channel)


	-- img = love.image.newImageData("color8.png")
	-- img_l = love.image.newImageData("ressource/image/pokemon.png")

	mario = love.image.newImageData("img/hi.png")

	to_send = {}

	for y=0, 31 do
		for x=0, 15 do
			local r, g, b = mario:getPixel(x, y)
			print_pixel(x, y, r, g, b, 1)
		end
	end

	for i = #to_send, 2, -1 do -- shuffle
		local j = math.random(i)
		to_send[i], to_send[j] = to_send[j], to_send[i]
	end
end

function love.draw()
	-- love.graphics.draw(img_l, 0,0)
end

function print_pixel(x,y, r, g, b, mul) 
	mul = mul or 0.15
	local str = string.format(
		'!matrix %d %d %d %d %d',
		x,
		y,
		math.floor(r*255*mul),
		math.floor(g*255*mul),
		math.floor(b*255*mul)
	)
	table.insert(to_send, str)
end

next_send = 2;
timer = 0
-- local pkm = 24

function love.update(dt)
	timer = timer + dt
	-- print(timer)

	if #to_send == 0 then
		-- to_send = {}
		-- pkm = love.math.random(0, img_l:getWidth())
		-- pkm = (pkm+1)%151
		-- print(pkm)
		-- for y=0, 7 do
		-- 	for x=0, 7 do
		-- 		local r, g, b = img_l:getPixel(x+pkm, y)
		-- 		-- local r, g, b = img:getPixel(x, y)
		-- 		print_pixel(x, y, r, g, b, 0.15)
		-- 	end
		-- end
		-- pkm = math.random(1, 151)
		
	
		-- img:mapPixel(function(x, y, r, g, b, a)
		-- 	print_pixel(x, y, r, g, b)
		-- 	return r,g,b,a
		-- end)

		-- for i = #to_send, 2, -1 do -- shuffle
		-- 	local j = math.random(i)
		-- 	to_send[i], to_send[j] = to_send[j], to_send[i]
		-- end
		-- print("HELLO", #to_send)
		-- next_send = timer + 60
	end
	-- print(next_send, timer)
	if timer > next_send then
		-- print("send")
		s:sendChat("#"..channel, to_send[#to_send])
		print(to_send[#to_send])
		table.remove(to_send, #to_send)
		next_send = timer + 1.6
	end
	s:think()
end

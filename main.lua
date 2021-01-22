love.filesystem.setRequirePath("?.lua;?/init.lua;lib/?.lua;lib/?/init.lua;lib/?/?.lua")
require "irc"
require("color")

local channel = "bot_ioodyme"

local bot = {
	{
		nick = "spectrenoir06_bot",
		oauth = "?"
	},
	{
		nick = "spectrenoir06",
		oauth = "?"
	},
}

local shuffle = true
local matrix_w = 16
local matrix_h = 32
local filter = "nearest"


local x, y = 0, 0
local next_send = 2;
local timer = 0
local to_send = {}

function love.load(arg)
	print(arg, arg[1])

	for k,v in ipairs(bot) do
		v.irc = irc.new{nick = v.nick}

		
		-- s:hook("OnChat",
		-- 	function(user, channel, message)
		-- 		print(("[%s] %s: %s"):format(channel, user.nick, message))
		-- 	end
		-- )
		
		
		v.irc:connect({
			host = "irc.chat.twitch.tv",
			password = "oauth:"..v.oauth,
		}, 6667)
		print("connect")
		
		v.irc:join("#"..channel)
		v.irc:think()
		
		v.irc:sendChat("#"..channel, "bonsoir @"..channel)
	end

	if arg[1] then
		local img = love.graphics.newImage(arg[1])
		img:setFilter(filter)
		canvas = love.graphics.newCanvas(matrix_w, matrix_h)
		canvas:renderTo(function()
			local kx, ky = matrix_w / img:getWidth(), matrix_h / img:getHeight()
			love.graphics.draw(img, 0, 0, 0, kx, ky)
		end)

		img_data = canvas:newImageData()
		canvas:setFilter("nearest")
	
		for y=0, matrix_h-1 do
			for x=0, matrix_w-1 do
				local r, g, b = img_data:getPixel(x, y)
				print_pixel(x, y, r, g, b, 1)
			end
		end
		
		if shuffle then
			for i = #to_send, 2, -1 do -- shuffle
				local j = math.random(i)
				to_send[i], to_send[j] = to_send[j], to_send[i]
			end
		end
	end

end

function love.draw()
	if (canvas) then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(canvas, 0,0, 0, 25, 25)
		love.graphics.setColor(1,0,0)
		love.graphics.rectangle("line", x*25, y*25, 25, 25)
	end
end

function print_pixel(x, y, r, g, b, mul) 
	mul = mul or 0.15
	local str = string.format(
		'!matrix %d %d %d %d %d',
		x,
		y,
		math.floor(r*255*mul),
		math.floor(g*255*mul),
		math.floor(b*255*mul)
	)
	table.insert(to_send, {
		cmd = str,
		x = x,
		y = y
	})
end

function love.update(dt)
	timer = timer + dt

	if timer > next_send and #to_send > 0 then
		for k,v in ipairs(bot) do
			v.irc:sendChat("#"..channel, to_send[#to_send].cmd)
			print(#to_send)
			print(to_send[#to_send].cmd)
			x = to_send[#to_send].x
			y = to_send[#to_send].y
			table.remove(to_send, #to_send)
		end
		next_send = timer + 1.7
	end
	for k,v in ipairs(bot) do
		v.irc:think()
	end
end

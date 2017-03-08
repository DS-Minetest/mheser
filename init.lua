--[[
        .__
  _____ |  |__   ____   ______ ___________
 /     \|  |  \_/ __ \ /  ___// __ \_  __ \
|  Y Y  \   Y  \  ___/ \___ \\  ___/|  | \/
|__|_|  /___|  /\___  >____  >\___  >__|
      \/     \/     \/     \/     \/
--]]

local load_time_start = os.clock()


minetest.register_entity("mheser:ent", {
	visual = "cube",
	collisionbox = {0,0,0, 0,0,0},
	visual_size = {x = 1.001, y = 1.001},
	textures = {"mheser_destroy.png", "mheser_destroy.png", "mheser_destroy.png",
		"mheser_destroy.png", "mheser_destroy.png", "mheser_destroy.png"},
	on_activate = function(self, staticdata)
		local pos = self.object:get_pos()
		local s = minetest.deserialize(staticdata)
		if s == nil then
			self.object:remove()
			return
		end
		local playername = s.player
		self.digtime = s.digtime
		self.starttime = s.starttime
		if playername == nil then
			self.object:remove()
			return
		end
		self.player = minetest.get_player_by_name(playername)
		if self.player == nil then
			self.object:remove()
			return
		end
		local playerpos = self.player:get_pos()
		self.sound = minetest.sound_play("mheser_sound_doing", {
				object = self.object,
				gain = 1.0,
				max_hear_distance = 32,
				loop = true,
			})
		for i = 0, vector.distance(pos, playerpos), 0.1 do
			local p = vector.add(playerpos, vector.multiply(vector.direction(playerpos, pos), i))
			minetest.add_particle({
					pos = p,
					velocity = {x=0, y=0, z=0},
					acceleration = {x=0, y=0, z=0},
					expirationtime = self.digtime,
					size = 1,
					collisiondetection = false,
					collision_removal = false,
					vertical = false,
					texture = "mheser_shoot.png",
					--~ playername = "singleplayer",
					--~ animation = {Tile Animation definition},
					glow = 10
			})
		end
	end,
	on_step = function(self, dtime)
		if not self.player or not self.player:get_player_control().RMB then
			minetest.sound_stop(self.sound)
			minetest.sound_play("mheser_sound_break", {
					object = self.object,
					gain = 1.0,
					max_hear_distance = 32,
					loop = false,
				})
			self.object:remove()
			return
		end
		if self.digtime <= os.clock() - self.starttime then
			minetest.remove_node(self.object:get_pos())
			minetest.sound_stop(self.sound)
			minetest.sound_play("mheser_sound_done", {
					object = self.object,
					gain = 1.0,
					max_hear_distance = 32,
					loop = false,
				})
			self.object:remove()
		end
	end,
})

minetest.register_craftitem("mheser:handcannon",{
	description = "Mheser",
	inventory_image = "mheser_handcannon.png",
	stack_max = 1,
	range = 0,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local look_dir = user:get_look_dir()
		local look_pos = vector.add(user:get_pos(), vector.divide(user:get_eye_offset(), 10))
		look_pos.y = look_pos.y + 1.625
		local range = 20
		local b, node_pos = minetest.line_of_sight(look_pos,
				vector.add(look_pos, vector.multiply(look_dir, range)), 1)
		if b then
			return
		end
		local s = {}
		s.digtime = 2
		s.starttime = os.clock()
		s.player = user:get_player_name()
		local staticdata = minetest.serialize(s)
		local ent = minetest.add_entity(node_pos, "mheser:ent", staticdata)
	end,
})


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[mheser] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end

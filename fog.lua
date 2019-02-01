--[[
Animated 2D Fog (procedural)
Originally for Godot Engine by Gonkee https://www.youtube.com/watch?v=QEaTsz_0o44&t=6s

Translated for löve by Brandon Blanker Lim-it @flamendless
]]--

return function(moonshine)
	local fog_color
	local octaves
	local speed

	local shader = love.graphics.newShader([[
		extern vec3 fog_color = vec3(0.35, 0.48, 0.95);
		extern int octaves = 4;
		extern vec2 speed = vec2(0.0, 1.0);
		extern float time;

		float rand(vec2 coord)
		{
			return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
		}

		float noise(vec2 coord)
		{
			vec2 i = floor(coord); //get the whole number
			vec2 f = fract(coord); //get the fraction number
			float a = rand(i); //top-left
			float b = rand(i + vec2(1.0, 0.0)); //top-right
			float c = rand(i + vec2(0.0, 1.0)); //bottom-left
			float d = rand(i + vec2(1.0, 1.0)); //bottom-right
			vec2 cubic = f * f * (3.0 - 2.0 * f);
			return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y; //interpolate
		}

		float fbm(vec2 coord) //fractal brownian motion
		{
			float value = 0.0;
			float scale = 0.5;
			for (int i = 0; i < octaves; i++)
			{
				value += noise(coord) * scale;
				coord *= 2.0;
				scale *= 0.5;
			}
			return value;
		}

		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
		{
			vec2 coord = tc * 20.0;
			vec2 motion = vec2(fbm(coord + vec2(time * speed.x, time * speed.y)));
			float final = fbm(coord + motion);
			return vec4(fog_color, final * 0.5);
		}
	]])

	local setters = {}

	setters.fog_color = function(t)
		assert(type(v) == "table", "Passed argument to fog_color must be a table containing 3 color values")
		fog_color = t
		shader:send("fog_color", fog_color)
	end

	setters.octaves = function(i)
		assert(type(i) == "number", "Passed argument to octaves must be an integer")
		octaves = i
		shader:send("octaves", octaves)
	end

	setters.speed = function(speed_x, speed_y)
		assert(type(speed_x) == "number", "Passed argument to speed must be a number (float)")
		assert(type(speed_y) == "number", "Passed argument to speed must be a number (float)")
		speed = {speed_x, speed_y}
		shader:send("speed", speed)
	end

	local defaults = {
		fog_color = {0.35, 0.48, 0.95},
		octaves = 4,
		speed = {0.5, 0.5},
	}

	return moonshine.Effect({
		name = "Fog",
		shader = shader,
		setters = setters,
		defaults = defaults,
	})
end

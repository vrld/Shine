--[[
Public domain:

Copyright (C) 2017 by Matthias Richter <vrld@vrld.org>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
]]--

return function(shine)
  local shader = love.graphics.newShader[[
    extern vec4 tint;
    extern number strength;
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {
      color = Texel(texture, tc);
      number luma = dot(vec3(0.299f, 0.587f, 0.114f), color.rgb);
      return mix(color, tint * luma, strength);
    }]]

  local setters = {}

  setters.tint = function(v)
    assert(type(v) == "table", "Invalid value for `tint'")
    shader:send("tint", v)
  end

  setters.strength = function(v)
    shader:send("strength", math.max(0, math.min(1, tonumber(v) or 0)))
  end

  local defaults = {color = {1.0,1.0,1.0,1.0}, strength = 0.5}

  return shine.Effect{shader = shader, setters = setters, defaults = defaults}
end

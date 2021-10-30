--[[ example-entity-with-tags
  * Copyright (c) 2019-2021 Goswin von Brederlow
  *
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  *
  * Example code showing how to use entity-with-tags in blueprints.
  * 
  * Permission granted to relicense when used in a larger project.
--]]

local tag_chest = table.deepcopy(data.raw["container"]["wooden-chest"])
tag_chest.name = "tag-chest"
tag_chest.minable = {mining_time = 1, result = "tag-chest"}
tag_chest.icon = "__core__/graphics/white-square.png"
tag_chest.icon_size = 10
tag_chest.icons = nil
tag_chest.picture =
  {
    layers =
      {
        {
          filename = "__core__/graphics/white-square.png",
          priority = "extra-high",
          width = 10,
          height = 10,
          shift = util.by_pixel(0.5, 0.5),
        }
      }
    }
    
data:extend {
  {
    type = "item-with-tags",
    name = "tag-chest",
    icon = "__core__/graphics/white-square.png",
    icon_size = 10,
    flags = {},
    subgroup = "other",
    order = "s[item-with-tags]-o[item-with-tags]",
    stack_size = 1,
    place_result = "tag-chest",
  },
  tag_chest,
  {
    type = "recipe",
    name = "tag-chest",
    ingredients = {},
    result = "tag-chest"
  },
}

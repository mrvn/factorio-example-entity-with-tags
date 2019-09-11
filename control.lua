--[[ example-entity-with-tags
  * Copyright (c) 2019 Goswin von Brederlow
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

rail_types = {}
rail_types["straight-rail"] = true
rail_types["curved-rail"] = true
rail_types["rail-signal"] = true
rail_types["rail-chain-signal"] = true
rail_types["train-stop"] = true

local function de_ghost_entity(entity)
  local name = entity.name
  if (name == "entity-ghost") then
    return entity.ghost_name, entity.ghost_type
  else
    return name, entity.prototype.type
  end
end

local function player_setup_blueprint(event)
  log("player_setup_blueprint")
  log(serpent.block(event))
  local player = game.players[event.player_index]
  local bp = player.blueprint_to_setup
  if not bp or not bp.valid_for_read then
    bp = player.cursor_stack
  end
  if not bp or not bp.valid_for_read then
    return
  end
  local entities = bp.get_blueprint_entities()
  if not entities then
    return
  end
  -- map blueprint entities to real entities
  -- bounding box for all entities
  local included_entities = {}
  for _, entity in ipairs(entities) do
    included_entities[entity.name] = true
  end
  local map_entities = player.surface.find_entities(event.area)
  local min_x = 2147483647
  local min_y = 2147483647
  local max_x = -2147483648
  local max_y = -2147483648
  local has_rails = false
  for _, entity in ipairs(map_entities) do
    local name, proto_type = de_ghost_entity(entity)
    if (not event.alt) or included_entities[name] then
      if rail_types[proto_type] then
        has_rails = true
      end
      local box = entity.bounding_box
      if box.left_top.x < min_x then min_x = box.left_top.x end
      if box.left_top.y < min_y then min_y = box.left_top.y end
      if box.right_bottom.x > max_x then max_x = box.right_bottom.x end
      if box.right_bottom.y > max_y then max_y = box.right_bottom.y end
    end
  end
  -- bounding box for all tiles
  local tiles = bp.get_blueprint_tiles()
  local included_tiles = {}
  local map_tiles = {}
  if tiles then
    for _, tile in ipairs(tiles) do
      included_tiles[tile.name] = true
    end
    map_tiles = player.surface.find_tiles_filtered{area=event.area}
    for _, tile in ipairs(map_tiles) do
      local name = tile.name
      if tile.prototype.can_be_part_of_blueprint and tile.prototype.items_to_place_this then
        if name == "tile-ghost" then name = tile.prototype.name end
        if (not event.alt) or included_tile[name] then
          local pos = tile.position
          log("tile " .. name .. " at (" .. tile.position.x .. ", " .. tile.position.y .. ")")
          if pos.x < min_x then min_x = pos.x end
          if pos.y < min_y then min_y = pos.y end
          if pos.x + 1 > max_x then max_x = pos.x + 1 end
          if pos.y + 1 > max_y then max_y = pos.y + 1 end
        end
      end
    end
  end
  local cx, cy
  if has_rails then
    cx = math.floor((math.floor(min_x) + math.ceil(max_x)) / 4) * 2 + 1
    cy = math.floor((math.floor(min_y) + math.ceil(max_y)) / 4) * 2 + 1
  else
    cx = math.floor((math.floor(min_x) + math.ceil(max_x)) / 2) + 0.5
    cy = math.floor((math.floor(min_y) + math.ceil(max_y)) / 2) + 0.5
  end
  log("estimated blueprint center: (" .. min_x .. ", " .. min_y .. ")-(" .. max_x .. ", " .. max_y .. ") ==> (" .. cx .. ", " .. cy .. ")")
  -- match entities
  local cache = {}
  for i, entity in ipairs(entities) do
    log("bp entity " .. i .. ": " .. entity.name .. " at (" .. entity.position.x .. ", " .. entity.position.y .. ")")
    cache[entity.position.x .. "_" .. entity.position.y .. "_" .. entity.name] = entity
  end
  
  for i, entity in ipairs(map_entities) do
    local name, proto_type = de_ghost_entity(entity)
    if included_entities[name] then
      log("map entity " .. i .. ": " .. entity.name .. "[" .. name .. "]" .. " at (" .. entity.position.x - cx .. ", " .. entity.position.y - cy .. ")")
      local bp_entity = cache[entity.position.x - cx .. "_" .. entity.position.y - cy .. "_" .. name]
      if bp_entity then
        if entity.name == "tag-chest" then
          -- set tag for our example tag-chest
          bp.set_blueprint_entity_tag(bp_entity.entity_number, "example-tag", entity.unit_number)
        end
      else
        log("ERROR: map entity not found in blueprint: " .. entity.name .. "[" .. name .. "]" .. " at (" .. entity.position.x - cx .. ", " .. entity.position.y - cy .. ")")
      end
    end
  end
end

function entity_built(event)
  local entity = event.created_entity
  log("entity_built: " .. entity.name)
  if entity and entity.name == "tag-chest" then
    log("  is tag-chest")
    local tags = event.tags
    if tags then
      log("    with tags")
      local data = tags["example-tag"]
      if data then
        log("      Entity build with example example-tag " .. data)
      else
        log("      example-tag missing")
      end
    else
      log("    tags missing")
    end
  end
end
  
script.on_event(defines.events.on_player_setup_blueprint, player_setup_blueprint)
script.on_event(defines.events.on_built_entity, entity_built)
script.on_event(defines.events.on_robot_built_entity, entity_built)
script.on_event(defines.events.script_raised_built, entity_built)

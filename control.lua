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
  -- get new blueprint or fake blueprint when selecting a new area
  local bp = player.blueprint_to_setup
  if not bp or not bp.valid_for_read then
    bp = player.cursor_stack
  end
  if not bp or not bp.valid_for_read then
    return
  end
  -- get entities in blueprint
  local entities = bp.get_blueprint_entities()
  if not entities then
    return
  end
  -- get mapping of blueprint entities to source entities
  if event.mapping.valid then
    local map = event.mapping.get()
    for _, bp_entity in pairs(entities) do
      if bp_entity.name == "tag-chest" then
        -- set tag for our example tag-chest
        local id = bp_entity.entity_number
        local entity = map[id]
        if entity then
          log("setting tag for bp_entity "..id..":"..bp_entity.name.." = "..entity.unit_number)
          bp.set_blueprint_entity_tag(id, "example-tag", entity.unit_number)
        else
          log("missing mapping for bp_entity "..id..":"..bp_entity.name)
        end
      end
    end
  else
    log("no entity mapping in event")
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

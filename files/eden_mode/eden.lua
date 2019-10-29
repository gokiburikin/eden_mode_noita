dofile( "data/scripts/utilities.lua" );
dofile( "data/scripts/perks/perk.lua" );
dofile( "data/scripts/perks/perk_list.lua" );
dofile( "files/eden_mode/config.lua");

function InitializeEden( player_entity )
    local init_check_flag = "eden_mode_init_done";
    if GameHasFlagRun( init_check_flag ) == false then
        GameAddFlagRun( init_check_flag );

        local x,y = EntityGetTransform( player_entity );
        SetRandomSeed( x - 216, y + 5182 );

        local inventory = nil;
        local cape = nil;

        local player_child_entities = EntityGetAllChildren( player_entity );
        if player_child_entities ~= nil then
            for i,child_entity in pairs( player_child_entities ) do
                local name = EntityGetName( child_entity );
                if name == "inventory_quick" then
                    inventory = child_entity;
                end
                if name == "cape" then
                    cape = child_entity;
                end
            end
        end

        -- random cape colour
        if cape ~= nil then
            edit_component( cape, "VerletPhysicsComponent", function( comp, vars ) 
                vars.cloth_color = Random( 0xFF000000, 0xFFFFFFFF );
                vars.cloth_color_edge = Random( 0xFF000000, 0xFFFFFFFF );
            end);
        end

        -- randomize starting hp
        local damage_models = EntityGetComponent( player_entity, "DamageModelComponent" );
        local x, y = EntityGetTransform( entity_item );

        if damage_models ~= nil then
            for i,v in pairs(damage_models) do
                local total = rand( MISC.Eden.MinimumHP * 0.04, MISC.Eden.MaximumHP * 0.04 );
                ComponentSetValue( v, "max_hp", total );
                ComponentSetValue( v, "hp", total );
            end
        end

        -- random wands
        if inventory ~= nil then
            local inventory_items = EntityGetAllChildren( inventory );
            
            if inventory_items ~= nil then
                for i,item_entity in ipairs( inventory_items ) do
                    GameKillInventoryItem( player_entity, item_entity );
                end
            end

            local actions_pool = {
                "projectile_actions",
                "cost_actions"
            }
            for i=1,2 do
                local item_entity = EntityLoad( "files/eden_mode/placeholder_wand.xml" );
                if item_entity then
                    EntityAddComponent( item_entity, "VariableStorageComponent", {
                        name = "eden_actions_pool",
                        value_string  = actions_pool[i],
                    });
                    EntityAddComponent( item_entity, "LuaComponent", {
                        execute_on_added = "1",
                        remove_after_executed = "1",
                        script_source_file = "files/eden_mode/eden_wand.lua"
                     } );

                    EntityAddChild( inventory, item_entity );
                end
            end
            for i=1,MISC.Eden.RandomFlasks do
                EntityAddChild( inventory, EntityLoad( "data/entities/items/pickup/potion.xml", Random( -1000, 1000 ), Random( -1000, 1000 ) ) );
            end
        end

        -- random perk
        local random_perk = random_from_array( perk_list ).id;
        local perk_entity = perk_spawn( x, y, random_perk );
        if perk_entity ~= nil then
            perk_pickup( perk_entity, player_entity, EntityGetName( perk_entity ), false, false );
        end
        
    end
end

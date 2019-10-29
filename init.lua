dofile( "files/eden_mode/config.lua");
function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    if MISC.Eden.Enabled then
        dofile("files/eden_mode/eden.lua");
        InitializeEden( player_entity );
    end
end

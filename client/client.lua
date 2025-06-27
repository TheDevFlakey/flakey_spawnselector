local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

RegisterNetEvent("flakey_spawnselector:openSpawnSelector", function()
   toggleNuiFrame(true)
end)

RegisterNUICallback("flakey_spawnselector:spawnPlayer", function(data, cb)
    local name = data.name
    local coords = data.coords
    if name and coords then
        if name ~= "Last Location" then
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
        end
        toggleNuiFrame(false)
        cb({ success = true, message = "Player spawned successfully." })
    else
        cb({ success = false, message = "Invalid data provided." })
    end
end)
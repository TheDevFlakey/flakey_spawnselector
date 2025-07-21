local cam = nil
local spawnLocations = {
    { name = "Last Location", coords = vector3(0, 0, 0) }, -- Placeholder for last location
    { name = "Legion Square", coords = vector3(215.76, -810.12, 30.73) },
    { name = "Sandy Shores", coords = vector3(1852.34, 3683.45, 34.27) },
    { name = "Paleto Bay", coords = vector3(-447.12, 6018.45, 31.72) },
    { name = "Los Santos International Airport", coords = vector3(-1034.56, -2737.89, 20.17) },
    { name = "Vespucci Beach", coords = vector3(-1600.23, -1070.45, 13.15) },
    { name = "Mount Chiliad", coords = vector3(-540.12, 5325.67, 74.23) }
}

local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage("setVisible", { visible = shouldShow, locations = spawnLocations })

    if not shouldShow and cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

RegisterNetEvent("flakey_spawnselector:openSpawnSelector", function(pos)
    local position = json.decode(pos)
    spawnLocations[1].coords = vector3(position.x, position.y, position.z) -- Update last location
    toggleNuiFrame(true)

    -- Set up initial overview camera above the city
    if not cam then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, spawnLocations[1].coords.x, spawnLocations[1].coords.y, spawnLocations[1].coords.z + 250.0) -- Above the city
        PointCamAtCoord(cam, spawnLocations[1].coords.x, spawnLocations[1].coords.y, spawnLocations[1].coords.z)
        SetCamRot(cam, -90.0, 0.0, 0.0) -- Top-down
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    end
end)

RegisterNUICallback("flakey_spawnselector:focusLocation", function(data, cb)
    local coords = data.coords
    if coords and cam then
        local from = GetCamCoord(cam)
        local to = vector3(coords.x, coords.y, coords.z + 250.0)

        -- Request collision for area
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)

        -- Optional: wait a little to ensure it loads properly
        CreateThread(function()
            local timer = GetGameTimer() + 1000
            while not HasCollisionLoadedAroundEntity(PlayerPedId()) and GetGameTimer() < timer do
                Wait(0)
            end
        end)

        local plyPed = PlayerPedId()
        SetEntityCoords(plyPed, coords.x, coords.y, coords.z, false, false, false, false)
        FreezeEntityPosition(plyPed, true)
        SetEntityVisible(plyPed, false)

        -- Smooth lerp to new camera position
        local duration = 0
        local startTime = GetGameTimer()

        CreateThread(function()
            while true do
                local now = GetGameTimer()
                local alpha = math.min(1.0, (now - startTime) / duration)
                local x = from.x + (to.x - from.x) * alpha
                local y = from.y + (to.y - from.y) * alpha
                local z = from.z + (to.z - from.z) * alpha

                SetCamCoord(cam, x, y, z)
                PointCamAtCoord(cam, coords.x, coords.y, coords.z)

                if alpha >= 1.0 then break end
                Wait(0)
            end
        end)
    end

    cb({ status = "ok" })
end)

RegisterNUICallback("flakey_spawnselector:spawnPlayer", function(data, cb)
    local name = data.name
    local coords = data.coords

    if name and coords then
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed)
        FreezeEntityPosition(plyPed, false)
        SetEntityVisible(plyPed, true)

        -- Smooth camera zoom-in
        if cam then
            SetEntityCoords(plyPed, coords.x, coords.y, coords.z, false, false, false, false)

            local from = GetCamCoord(cam)
            local to = vector3(plyCoords.x, plyCoords.y, plyCoords.z + 2.0) -- Just above player height
            local duration = 1000
            local startTime = GetGameTimer()

            CreateThread(function()
                while true do
                    local now = GetGameTimer()
                    local alpha = math.min(1.0, (now - startTime) / duration)
                    local x = from.x + (to.x - from.x) * alpha
                    local y = from.y + (to.y - from.y) * alpha
                    local z = from.z + (to.z - from.z) * alpha

                    SetCamCoord(cam, x, y, z)
                    PointCamAtCoord(cam, coords.x, coords.y, coords.z)

                    if alpha >= 1.0 then
                        -- Hide UI after zoom completes
                        toggleNuiFrame(false)

                        cb({ success = true, message = "Player spawned successfully." })
                        break
                    end
                    Wait(0)
                end
            end)
        else
            -- Fallback if no camera exists
            SetEntityCoords(plyPed, coords.x, coords.y, coords.z, false, false, false, false)
            toggleNuiFrame(false)
            cb({ success = true, message = "Player spawned successfully." })
        end
    else
        cb({ success = false, message = "Invalid data provided." })
    end
end)

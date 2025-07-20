local cam = nil
local lastLocationCoords = nil
local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage("setVisible", shouldShow)

    if not shouldShow and cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

RegisterNetEvent("flakey_spawnselector:openSpawnSelector", function()
    toggleNuiFrame(true)

    -- Set up initial overview camera above the city
    if not cam then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, 405.0, -1000.0, 420.0) -- Above the city
        PointCamAtCoord(cam, 405.0, -1000.0, 0.0)
        SetCamRot(cam, -90.0, 0.0, 0.0) -- Top-down
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    end
    lastLocationCoords = GetEntityCoords(PlayerPedId())
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
        FreezeEntityPosition(plyPed, false)
        SetEntityVisible(plyPed, true)
        if name == "Last Location" then
            SetEntityCoords(plyPed, lastLocationCoords.x, lastLocationCoords.y, lastLocationCoords.z, false, false, false, false)
        else
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
        end
        toggleNuiFrame(false)
        cb({ success = true, message = "Player spawned successfully." })
    else
        cb({ success = false, message = "Invalid data provided." })
    end
end)

-- Preserve the original device, event ordering, and all non-horizontal input.
libinput:register({1})
libinput:connect("new-evdev-device", function(device)
    local info = device:info()
    if info.vid ~= 0x3434 or (info.pid ~= 0xd049 and info.pid ~= 0xd028) then
        return
    end
    local usages = device:usages()
    if not usages[evdev.REL_HWHEEL] and not usages[evdev.REL_HWHEEL_HI_RES] then
        return
    end
    device:connect("evdev-frame", function(_, frame, _)
        local modified = false
        for _, event in ipairs(frame) do
            if event.usage == evdev.REL_HWHEEL or event.usage == evdev.REL_HWHEEL_HI_RES then
                event.value = event.value * 2
                modified = true
            end
        end
        if modified then return frame end
    end)
    device:connect("device-removed", function(_) end)
end)

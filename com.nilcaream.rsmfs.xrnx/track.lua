require("common")

Track = {}
Track.__index = Track

function Track:new(_table, ticks_per_beat, resolution)
    resolution = resolution or 1
    local tick = ticks_per_beat / (renoise.song().transport.lpb * resolution)

    local instance = { }

    for index, value in ipairs(_table) do
        table.insert(instance, {
            note_number = value.note_number,
            note = value.note,
            start_position = value.start_time / tick,
            end_position = value.end_time / tick,
            velocity = value.velocity
        })
    end
    setmetatable(instance, Track)
    return instance
end

function Track:print()
    for index, value in ipairs(self) do
        log("Track line: % 2d, start: %6.2f, end: %6.2f, note: %3s (% 3d), velocity: % 3d", index, value.start_position, value.end_position, value.note, value.note_number, value.velocity)
    end
end

-- =========================================

function Track.add_raw(note, tracks)
    for track_index = 1, 16 do
        if tracks[track_index] == nil then
            table.insert(tracks, {})
        end

        local track = tracks[track_index]

        if #track == 0 then
            table.insert(track, note)
            return
        else
            local last_note = track[#track]
            if note.start_time >= last_note.end_time then
                table.insert(tracks[track_index], note)
                return
            end
        end
    end
end

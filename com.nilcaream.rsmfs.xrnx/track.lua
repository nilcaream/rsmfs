require("common")

Track = {}
Track.__index = Track

function Track:new(_table, ticks_per_beat)
    local resolution = rsmfs.options.resolution / 4
    local tick = ticks_per_beat / (renoise.song().transport.lpb * resolution)

    local instance = { }

    for index, value in ipairs(_table) do
        table.insert(instance, {
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
        log("start: %6.2f, end: %6.2f, note: %3s, velocity: % 3d", value.start_position, value.end_position, value.note, value.velocity)
    end
end

-- =========================================

function Track.add_raw(midi_note, tracks)
    for track_index = 1, 16 do
        if tracks[track_index] == nil then
            table.insert(tracks, {})
        end

        local track = tracks[track_index]

        if #track == 0 then
            table.insert(track, midi_note)
            return
        else
            local last_note = track[#track]
            if midi_note.start_time >= last_note.end_time then
                table.insert(tracks[track_index], midi_note)
                return
            end
        end
    end
end

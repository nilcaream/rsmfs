require("common")

rsmfs.note_columns = {}
rsmfs.note_columns.__index = rsmfs.note_columns

function rsmfs.note_columns:new(ticks_per_beat)
    local instance = {
        renoise_note_columns = {},
        tick = ticks_per_beat / (renoise.song().transport.lpb * rsmfs.options.resolution / 4)
    }
    setmetatable(instance, rsmfs.note_columns)
    return instance
end

function rsmfs.note_columns:add_midi_note(midi_note)
    for column_index = 1, 12 do
        if self.renoise_note_columns[column_index] == nil then
            self.renoise_note_columns[column_index] = {}
        end

        local renoise_note_column = self.renoise_note_columns[column_index]

        if #renoise_note_column == 0 then
            table.insert(renoise_note_column, self:to_renoise_note(midi_note))
            return
        else
            local last_renoise_note = renoise_note_column[#renoise_note_column]
            if midi_note.start_time >= last_renoise_note.end_time then
                table.insert(renoise_note_column, self:to_renoise_note(midi_note))
                return
            end
        end
    end
end

function rsmfs.note_columns:to_renoise_note(midi_note)
    local start_position = midi_note.start_time / self.tick
    local end_position = midi_note.end_time / self.tick
    local end_time = midi_note.end_time

    if rsmfs.options.correct_positions then
        if start_position - math.floor(start_position) > 0.98 then
            rsmfs.log("Correcting start note position from %.2f to %.2f", start_position, math.ceil(start_position))
            start_position = math.ceil(start_position)
        end

        if end_position - math.floor(end_position) > 0.98 then
            rsmfs.log("Correcting end note position from %.2f to %.2f", end_position, math.ceil(end_position))
            end_time = end_time * math.ceil(end_position) / end_position
            end_position = math.ceil(end_position)
        end
    end

    return {
        note = midi_note.note,
        start_position = start_position,
        end_position = end_position,
        end_time = end_time,
        velocity = midi_note.velocity
    }
end

function rsmfs.note_columns:get_renoise_note_columns()
    return self.renoise_note_columns
end

function rsmfs.note_columns:print(column_index)
    for index, renoise_note in ipairs(self.renoise_note_columns[column_index]) do
        rsmfs.log("start: %6.2f, end: %6.2f, note: %3s, velocity: % 3d", renoise_note.start_position, renoise_note.end_position, renoise_note.note, renoise_note.velocity)
    end
end

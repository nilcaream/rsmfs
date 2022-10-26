require("common")

rsmfs.workplace = {}
rsmfs.workplace.__index = rsmfs.workplace

function rsmfs.workplace:new()
    local instance = {
        pattern_track = renoise.song().selected_pattern_track,
        track_index = renoise.song().selected_track_index,
        track = renoise.song().selected_track,
        pattern = renoise.song().selected_pattern,
        instrument = renoise.song().selected_instrument_index,
        line_index = renoise.song().selected_line_index,
        note_column_index = math.max(1, renoise.song().selected_note_column_index) -- 0 when effect column is selected
    }
    setmetatable(instance, rsmfs.workplace)
    return instance
end

function rsmfs.workplace:prepare(note_columns_number)
    local number_of_lines = self.pattern.number_of_lines
    local line_index_offset = 0
    local note_column_index_offset = 0

    if rsmfs.options.insert_at_cursor then
        line_index_offset = self.line_index - 1
        note_column_index_offset = self.note_column_index - 1
    end

    if rsmfs.options.clear_existing_notes then
        self.pattern.number_of_lines = 512
        for index, line in ipairs(self.pattern_track.lines) do
            if index > line_index_offset then
                line:clear()
            end
        end
        self.pattern.number_of_lines = number_of_lines
    end

    local add_note_columns = self.track.visible_note_columns < (note_columns_number + note_column_index_offset) and rsmfs.options.add_note_columns
    local remove_note_columns = self.track.visible_note_columns > (note_columns_number + note_column_index_offset) and rsmfs.options.remove_note_columns

    if add_note_columns or remove_note_columns then
        if note_columns_number + note_column_index_offset > 12 then
            rsmfs.log("To many note colums: %d. Limiting to 12", note_columns_number + note_column_index_offset)
            self.track.visible_note_columns = 12
        else
            self.track.visible_note_columns = note_columns_number + note_column_index_offset
        end
    end

    if rsmfs.options.include_note_off then
        for i = 1 + note_column_index_offset, math.min(12, note_columns_number + note_column_index_offset) do
            self.pattern_track:line(1 + line_index_offset):note_column(i).note_string = "OFF"
        end
    end

    self.track.volume_column_visible = true
    self.track.delay_column_visible = true
end

function rsmfs.workplace:update(note_column_index, renoise_note_column)
    local max_end_position = 1
    local offset_position = 0

    if rsmfs.options.insert_at_cursor then
        offset_position = self.line_index - 1
        note_column_index = note_column_index + self.note_column_index - 1
    end

    if note_column_index > 12 then
        rsmfs.log("Skipping note column " .. note_column_index)
        return
    end

    for index, renoise_note_column_line in ipairs(renoise_note_column) do
        local start_position = offset_position + math.floor(renoise_note_column_line.start_position)
        local end_position = offset_position + math.floor(renoise_note_column_line.end_position)

        max_end_position = math.max(max_end_position, end_position)

        if start_position >= 512 then
            rsmfs.log("Skipping note-on outside of max pattern line range - start: %d, end: %d", start_position, end_position)
            break
        end

        -- rsmfs.log("Update - line: %d, note: %s, start: %d, end: %d", line_index, pre_track_entry.note, start_position, end_position)

        self.pattern_track:line(start_position + 1):note_column(note_column_index).instrument_value = self.instrument - 1

        if rsmfs.options.include_velocity and renoise_note_column_line.velocity < 127 then
            self.pattern_track:line(start_position + 1):note_column(note_column_index).volume_value = renoise_note_column_line.velocity
        end

        self.pattern_track:line(start_position + 1):note_column(note_column_index).note_string = renoise_note_column_line.note
        if rsmfs.options.include_delay and start_position < renoise_note_column_line.start_position + offset_position then
            local delay = math.floor((renoise_note_column_line.start_position + offset_position - start_position) * 256)
            self.pattern_track:line(start_position + 1):note_column(note_column_index).delay_value = delay
        end

        if end_position >= 512 then
            rsmfs.log("Skipping note-off outside of max pattern line range - start: %d, end: %d", start_position, end_position)
            break
        end

        if rsmfs.options.include_note_off then
            self.pattern_track:line(end_position + 1):note_column(note_column_index).note_string = "OFF"
            if rsmfs.options.include_delay and end_position < renoise_note_column_line.end_position + offset_position then
                local delay = math.floor((renoise_note_column_line.end_position + offset_position - end_position) * 256)
                self.pattern_track:line(end_position + 1):note_column(note_column_index).delay_value = delay
            end
        end
    end

    local increase_number_of_lines = max_end_position > self.pattern.number_of_lines and rsmfs.options.increase_number_of_lines
    local decrease_number_of_lines = max_end_position < self.pattern.number_of_lines and rsmfs.options.decrease_number_of_lines

    if increase_number_of_lines or decrease_number_of_lines then
        self.pattern.number_of_lines = math.min(512, max_end_position)
    end
end

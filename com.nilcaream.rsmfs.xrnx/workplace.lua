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
        line_index_offset = 0,
        note_column_index_offset = 0,
    }

    if rsmfs.options.insert_at_cursor then
        instance.line_index_offset = renoise.song().selected_line_index - 1
        instance.note_column_index_offset = math.max(1, renoise.song().selected_note_column_index) - 1
    end

    setmetatable(instance, rsmfs.workplace)
    return instance
end

function rsmfs.workplace:prepare(note_columns_number, number_of_lines_needed)

    if rsmfs.options.clear_existing_notes then
        local number_of_lines = self.pattern.number_of_lines
        self.pattern.number_of_lines = 512
        for index, line in ipairs(self.pattern_track.lines) do
            if index > self.line_index_offset then
                line:clear()
            end
        end
        self.pattern.number_of_lines = number_of_lines
    end

    local effective_note_columns_number = note_columns_number + self.note_column_index_offset
    local add_note_columns = self.track.visible_note_columns < effective_note_columns_number and rsmfs.options.add_note_columns
    local remove_note_columns = self.track.visible_note_columns > effective_note_columns_number and rsmfs.options.remove_note_columns

    if add_note_columns or remove_note_columns then
        self.track.visible_note_columns = math.min(12, effective_note_columns_number)
    end

    local effective_number_of_lines = number_of_lines_needed + self.line_index_offset
    local increase_number_of_lines = self.pattern.number_of_lines < effective_number_of_lines and rsmfs.options.increase_number_of_lines
    local decrease_number_of_lines = self.pattern.number_of_lines > effective_number_of_lines and rsmfs.options.decrease_number_of_lines

    if increase_number_of_lines or decrease_number_of_lines then
        self.pattern.number_of_lines = math.min(512, effective_number_of_lines)
    end

    self.track.volume_column_visible = true
    self.track.delay_column_visible = true
end

function rsmfs.workplace:update(note_column_index, renoise_note_column)
    local effective_note_column_index = note_column_index + self.note_column_index_offset

    if effective_note_column_index > 12 then
        rsmfs.log("Skipping note column " .. effective_note_column_index)
        return
    end

    for index, renoise_note_column_line in ipairs(renoise_note_column) do
        local start_position = self.line_index_offset + math.floor(renoise_note_column_line.start_position)
        local end_position = self.line_index_offset + math.floor(renoise_note_column_line.end_position)

        if start_position >= 512 then
            rsmfs.log("Skipping note-on outside of max pattern line range - start: %d, end: %d", start_position, end_position)
            break
        end

        local start_cell = self.pattern_track:line(start_position + 1):note_column(effective_note_column_index)
        local start_delay = math.floor((renoise_note_column_line.start_position + self.line_index_offset - start_position) * 256)

        start_cell.note_string = renoise_note_column_line.note
        start_cell.instrument_value = self.instrument - 1

        if rsmfs.options.include_velocity and renoise_note_column_line.velocity < 127 then
            start_cell.volume_value = renoise_note_column_line.velocity
        end
        if rsmfs.options.include_delay and start_delay > 0 then
            start_cell.delay_value = start_delay
        end

        if end_position >= 512 then
            rsmfs.log("Skipping note-off outside of max pattern line range - start: %d, end: %d", start_position, end_position)
            break
        end

        local end_cell = self.pattern_track:line(end_position + 1):note_column(effective_note_column_index)
        local end_delay = math.floor((renoise_note_column_line.end_position + self.line_index_offset - end_position) * 256)

        if rsmfs.options.include_note_off then
            end_cell.note_string = "OFF"
            if rsmfs.options.include_delay and end_delay > 0 then
                end_cell.delay_value = end_delay
            end
        end
    end
end

require("common")

rsmfs.workplace = {}
rsmfs.workplace.__index = rsmfs.workplace

function rsmfs.workplace:new()
    local instance = {
        pattern_track = renoise.song().selected_pattern_track,
        track_index = renoise.song().selected_track_index,
        track = renoise.song().selected_track,
        pattern = renoise.song().selected_pattern,
        instrument = renoise.song().selected_instrument_index - 1
    }
    setmetatable(instance, rsmfs.workplace)
    return instance
end

function rsmfs.workplace:prepare(track_lines_number)
    local number_of_lines = self.pattern.number_of_lines

    self.pattern.number_of_lines = 512
    for index, line in ipairs(self.pattern_track.lines) do
        line:clear()
    end
    self.pattern.number_of_lines = number_of_lines

    local add_note_columns = self.track.visible_note_columns < track_lines_number and rsmfs.options.add_note_columns
    local remove_note_columns = self.track.visible_note_columns > track_lines_number and rsmfs.options.remove_note_columns

    if add_note_columns or remove_note_columns then
        self.track.visible_note_columns = track_lines_number
    end

    for i = 1, self.track.visible_note_columns do
        self.pattern_track:line(1):note_column(i).note_string = "OFF"
    end

    self.track.volume_column_visible = true
    self.track.delay_column_visible = true
end

function rsmfs.workplace:update(note_column_index, renoise_note_column)
    local max_end_position = 1

    -- TODO check note_column_index vs. max Renoise note column count

    for index, renoise_note_column_line in ipairs(renoise_note_column) do
        local start_position = math.floor(renoise_note_column_line.start_position)
        local end_position = math.floor(renoise_note_column_line.end_position)

        max_end_position = math.max(max_end_position, end_position)

        if start_position >= 512 then
            rsmfs.log("Skipping note-on outside of max pattern line range - start: %d, end: %d", start_position, end_position)
            break
        end

        -- rsmfs.log("Update - line: %d, note: %s, start: %d, end: %d", line_index, pre_track_entry.note, start_position, end_position)

        self.pattern_track:line(start_position + 1):note_column(note_column_index).instrument_value = self.instrument

        if rsmfs.options.include_velocity and renoise_note_column_line.velocity < 127 then
            self.pattern_track:line(start_position + 1):note_column(note_column_index).volume_value = renoise_note_column_line.velocity
        end

        self.pattern_track:line(start_position + 1):note_column(note_column_index).note_string = renoise_note_column_line.note
        if start_position < renoise_note_column_line.start_position then
            local delay = math.floor((renoise_note_column_line.start_position - start_position) * 256)
            self.pattern_track:line(start_position + 1):note_column(note_column_index).delay_value = delay
        end

        if end_position >= 512 then
            rsmfs.log("Skipping note-off outside of max pattern line range - start: %d, end: %d", start_position, end_position)
            break
        end

        self.pattern_track:line(end_position + 1):note_column(note_column_index).note_string = "OFF"
        if end_position < renoise_note_column_line.end_position then
            local delay = math.floor((renoise_note_column_line.end_position - end_position) * 256)
            self.pattern_track:line(end_position + 1):note_column(note_column_index).delay_value = delay
        end
    end

    local increase_number_of_lines = max_end_position > self.pattern.number_of_lines and rsmfs.options.increase_number_of_lines
    local decrease_number_of_lines = max_end_position < self.pattern.number_of_lines and rsmfs.options.decrease_number_of_lines

    if increase_number_of_lines or decrease_number_of_lines then
        self.pattern.number_of_lines = math.min(512, max_end_position)
    end
end

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
    for index, line in ipairs(self.pattern_track.lines) do
        line:clear()
    end

    local add_note_columns = self.track.visible_note_columns < track_lines_number and rsmfs.options.add_note_columns
    local remove_note_columns = self.track.visible_note_columns > track_lines_number and rsmfs.options.remove_note_columns

    if add_note_columns or remove_note_columns then
        self.track.visible_note_columns = track_lines_number
    end
end

function rsmfs.workplace:update(pre_track_entries, line_index)
    local max_end_position = 1

    for index, pre_track_entry in ipairs(pre_track_entries) do
        local start_position = math.floor(pre_track_entry.start_position)
        local end_position = math.floor(pre_track_entry.end_position)

        max_end_position = math.max(max_end_position, end_position)
        -- rsmfs.log("Update %s %d %d", pre_track_entry.note, start_position, end_position)

        self.pattern_track:line(start_position + 1):note_column(line_index).instrument_value = self.instrument
        self.pattern_track:line(start_position + 1):note_column(line_index).volume_value = pre_track_entry.velocity

        self.pattern_track:line(start_position + 1):note_column(line_index).note_string = pre_track_entry.note
        self.pattern_track:line(end_position + 1):note_column(line_index).note_string = "OFF"

        if start_position < pre_track_entry.start_position then
            local delay = math.floor((pre_track_entry.start_position - start_position) * 256)
            self.pattern_track:line(start_position + 1):note_column(line_index).delay_value = delay
        end

        if end_position < pre_track_entry.end_position then
            local delay = math.floor((pre_track_entry.end_position - end_position) * 256)
            self.pattern_track:line(end_position + 1):note_column(line_index).delay_value = delay
        end
    end

    local increase_number_of_lines = max_end_position > self.pattern.number_of_lines and rsmfs.options.increase_number_of_lines
    local decrease_number_of_lines = max_end_position < self.pattern.number_of_lines and rsmfs.options.decrease_number_of_lines

    if increase_number_of_lines or decrease_number_of_lines then
        self.pattern.number_of_lines = max_end_position
    end
end

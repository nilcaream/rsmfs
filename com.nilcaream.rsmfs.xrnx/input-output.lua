require("common")
require("options")
require("midi-note")
require("workplace")
require("note-columns")

rsmfs.midi = require("MIDI")

rsmfs.io = {}

rsmfs.io.read_file = function(filename)
    local file = io.open(filename, "rb")
    local result

    if file == nil then
        return nil
    end

    file:seek("set", 0)
    result = file:read("*a")
    io.close(file)

    return result
end

rsmfs.io.select_and_load_midi_file = function()
    local filename = renoise.app():prompt_for_filename_to_read({ "*" }, "Select midi file to load") or ""

    if filename ~= "" then
        local lower = string.lower(filename)
        if lower:match(".+\.mid") or lower:match(".+\.xrmid") then
            if rsmfs.options.conditionally_show() == true then
                return rsmfs.io.load_midi_file(filename)
            end
        else
            rsmfs.status("Unsupported file " .. filename)
        end
    end
end

rsmfs.io.load_midi_file = function(filename)
    rsmfs.log("-------- Loading " .. filename)

    local midi = rsmfs.io.read_file(filename)
    local score = rsmfs.midi.midi2score(midi)
    local stats = rsmfs.midi.score2stats(score)

    rsmfs.log("Tracks: " .. stats.ntracks)
    rsmfs.log("Total ticks: " .. stats.nticks)
    rsmfs.log("Ticks per beat: " .. score[1])

    local note_columns = rsmfs.note_columns:new(score[1])

    rsmfs.log("-------- Raw midi input")

    for itrack = 2, #score do
        for _, event in ipairs(score[itrack]) do

            if event[1] == "note" then
                local midi_note = rsmfs.midi_note:new(event)
                rsmfs.log(midi_note:__tostring())
                note_columns:add_midi_note(midi_note)
            end
        end
    end

    local renoise_note_columns = note_columns:get_renoise_note_columns()
    local workplace = rsmfs.workplace:new()

    workplace:prepare(#renoise_note_columns, note_columns:get_maximum_renoise_end_position())

    for note_column_index, renoise_note_column in ipairs(renoise_note_columns) do
        rsmfs.log("-------- Note column " .. note_column_index)
        note_columns:print(note_column_index)
        workplace:update(note_column_index, renoise_note_column)
    end

    rsmfs.status("Loaded " .. filename)

    return true
end

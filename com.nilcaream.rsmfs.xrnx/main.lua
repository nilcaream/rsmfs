require("common")

require("midi-note")
require("workplace")
require("options")
require("note-columns")

rsmfs.main = {}

rsmfs.midi = require("MIDI")

rsmfs.main.load = function(filename)
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

rsmfs.main.import_xrmid = function(filename)
    if rsmfs.options.show_for_each_file then
        if rsmfs.options.configure() ~= "OK" then
            return false
        end
    end

    return rsmfs.main.import(filename)
end

rsmfs.main.import = function(filename)
    rsmfs.log("-------- Loading " .. filename)

    local midi = rsmfs.main.load(filename)
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
    workplace:prepare(#renoise_note_columns)

    for note_column_index, renoise_note_column in ipairs(renoise_note_columns) do
        rsmfs.log("-------- Note column " .. note_column_index)
        note_columns:print(note_column_index)
        workplace:update(note_column_index, renoise_note_column)
    end

    return true
end

rsmfs.main.init = function()
    local integration = { category = "instrument",
                          extensions = { "xrmid" },
                          invoke = rsmfs.main.import_xrmid }

    if renoise.tool():has_file_import_hook(integration.category, integration.extensions) == false then
        renoise.tool():add_file_import_hook(integration)
    else
        log("Import hook already present")
    end
end

-- =========================================

rsmfs.main.init()
rsmfs.options.init()

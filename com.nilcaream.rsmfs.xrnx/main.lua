require("common")

require("midi-note")
require("track")
require("workplace")
require("options")

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

rsmfs.main.import = function(filename)

    if rsmfs.options.show_for_each_file then
        if rsmfs.options.show() == "Cancel" then
            return false
        end
    end

    rsmfs.log("-------- Loading " .. filename)

    local midi = rsmfs.main.load(filename)
    local score = rsmfs.midi.midi2score(midi)
    local stats = rsmfs.midi.score2stats(score)

    rsmfs.log("Tracks: " .. stats.ntracks)
    rsmfs.log("Total ticks: " .. stats.nticks)
    rsmfs.log("Ticks per beat: " .. score[1])

    local raw_track_lines = { }

    rsmfs.log("-------- Raw midi input")

    for itrack = 2, #score do
        for _, event in ipairs(score[itrack]) do

            -- TODO check if this is always sorted by start_time; filter by channel if needed
            if event[1] == "note" then
                local midi_note = rsmfs.midi_note:new(event)
                rsmfs.log(midi_note:__tostring())
                rsmfs.track.add_raw(midi_note, raw_track_lines)
            end
        end
    end

    local workplace = rsmfs.workplace:new()
    workplace:prepare(#raw_track_lines)

    for index, value in ipairs(raw_track_lines) do
        rsmfs.log("-------- Note column " .. index)
        local track = rsmfs.track:new(value, score[1])
        track:print()
        workplace:update(track, index)
    end

    return true
end

rsmfs.main.init = function()
    local integration = { category = "instrument",
                          extensions = { "xrmid" },
                          invoke = rsmfs.main.import }

    if renoise.tool():has_file_import_hook(integration.category, integration.extensions) == false then
        renoise.tool():add_file_import_hook(integration)
    else
        log("Import hook already present")
    end
end

-- =========================================

rsmfs.main.init()
rsmfs.options.init()

require("common")

local MIDI = require("MIDI")

require("note")
require("track")

function load_file(filename)
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

function mid_import(filename)
    log("-------- Loading " .. filename)

    local midi = load_file(filename)
    local score = MIDI.midi2score(midi)
    local stats = MIDI.score2stats(score)

    log("Tracks: " .. stats.ntracks)
    log("Total ticks: " .. stats.nticks)
    log("Ticks per beat: " .. score[1])

    local tracks = { }

    log("-------- Raw midi input")

    for itrack = 2, #score do
        for _, event in ipairs(score[itrack]) do

            -- TODO check if this is always sorted by start_time; filter by channel
            if event[1] == "note" then
                local note = Note:new(event)
                log(note:__tostring())
                Track.add_raw(note, tracks)
            end
        end
    end

    for index, value in ipairs(tracks) do
        log("-------- Track " .. index)
        local track = Track:new(value, score[1])
        track:print()
    end

    return true
end

-- =========================================

local integration = { category = "instrument",
                      extensions = { "xrmid" },
                      invoke = mid_import }

if renoise.tool():has_file_import_hook(integration.category, integration.extensions) == false then
    renoise.tool():add_file_import_hook(integration)
else
    log("Import hook already present")
end

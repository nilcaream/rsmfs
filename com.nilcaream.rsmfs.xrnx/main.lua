-- Renoise Simple Midi File Support

function log(s, ...)
    print("RSMFS " .. string.format(s, ...))
end

log("Renoise Simple Midi File Support")

local MIDI = require("MIDI")

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

local notes_sharp = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

function to_note(midi_note_number, _dictionary)
    -- https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
    local dictionary = _dictionary or notes_sharp
    local note_index = midi_note_number % #dictionary
    local octave = math.floor(midi_note_number / #dictionary) - 1
    local note = dictionary[note_index + 1]

    if #note == 1 then
        return note .. "-" .. octave
    else
        return note .. octave
    end
end

function mid_import(filename)
    --renoise.app():show_status("Importing midi file " .. filename)
    log("Loading " .. filename)
    local midi = load_file(filename)
    local score = MIDI.midi2score(midi)
    local stats = MIDI.score2stats(score)
    log("Tracks: " .. stats.ntracks)
    log("Total ticks: " .. stats.nticks)
    log("Ticks: " .. score[1])

    for itrack = 2, #score do
        for _, event in ipairs(score[itrack]) do
            -- {'note', start_time, duration, channel, note, velocity}
            if event[1] == 'note' then
                local note = to_note(event[5])
                local start_time = event[2]
                local duration = event[3]
                local end_time = start_time + duration
                local channel = event[4]
                local velocity = event[6]
                log("CH: %s, start: % 5d, end: % 5d, note: %3s (% 3d), velocity: % 3d", channel, start_time, end_time, note, event[5], velocity)
            end
        end
    end

    return true
end

-- import hook

local mid_integration = { category = "instrument",
                          extensions = { "xrmid" },
                          invoke = mid_import }

if renoise.tool():has_file_import_hook(mid_integration.category, mid_integration.extensions) == false then
    renoise.tool():add_file_import_hook(mid_integration)
    log("Added import hook")
else
    log("Import hook already present")
end

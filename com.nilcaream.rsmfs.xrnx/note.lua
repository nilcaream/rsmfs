Note = {}
Note.__index = Note

function Note:new(event)
    local instance = {
        note_number = event[5],
        note = resolve_midi_note_number(event[5]),
        start_time = event[2],
        end_time = event[2] + event[3],
        duration = event[3],
        channel = event[4],
        velocity = event[6]
    }
    setmetatable(instance, Note)
    return instance
end

function Note:__tostring()
    return string.format("CH: %s, start: % 5d, end: % 5d, note: %3s (% 3d), velocity: % 3d", self.channel, self.start_time, self.end_time, self.note, self.note_number, self.velocity)
end

-- =========================================

local notes_sharp = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

function resolve_midi_note_number(midi_note_number, _dictionary)
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

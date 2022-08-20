require("common")

rsmfs.midi_note = {}
rsmfs.midi_note.__index = rsmfs.midi_note
rsmfs.midi_note.notes_sharp = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

function rsmfs.midi_note:new(event)
    local instance = {
        note_number = event[5],
        note = rsmfs.midi_note.to_note_string(event[5]),
        start_time = event[2],
        end_time = event[2] + event[3],
        duration = event[3],
        channel = event[4],
        velocity = event[6]
    }
    setmetatable(instance, rsmfs.midi_note)
    return instance
end

function rsmfs.midi_note:__tostring()
    return string.format("CH: %s, start: % 5d, end: % 5d, note: %3s (% 3d), velocity: % 3d", self.channel, self.start_time, self.end_time, self.note, self.note_number, self.velocity)
end

-- =========================================

-- https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
rsmfs.midi_note.to_note_string = function(midi_note_number, dictionary)
    midi_note_number = midi_note_number + 12 * rsmfs.options.octave + rsmfs.options.transposition
    dictionary = dictionary or rsmfs.midi_note.notes_sharp

    local note_index = midi_note_number % #dictionary
    local octave = math.floor(midi_note_number / #dictionary) - 1
    local note = dictionary[note_index + 1]

    if #note == 1 then
        return note .. "-" .. octave
    else
        return note .. octave
    end
end

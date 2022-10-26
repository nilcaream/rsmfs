require("common")

rsmfs.options = {
    add_note_columns = true,
    remove_note_columns = true,
    increase_number_of_lines = true,
    decrease_number_of_lines = true,
    resolution = 4,
    transposition = 0,
    octave = 1,
    show_for_each_file = true,
    include_velocity = true,
    include_delay = true,
    include_note_off = true,
    correct_positions = false,
    insert_at_cursor = false,
    clear_existing_notes = true
}

rsmfs.options.init = function()
    renoise.tool():add_menu_entry {
        name = "Main Menu:Tools:Renoise Simple Midi File Support:Import midi file",
        invoke = rsmfs.io.select_and_load_midi_file
    }

    renoise.tool():add_menu_entry {
        name = "Main Menu:Tools:Renoise Simple Midi File Support:Options",
        invoke = rsmfs.options.show
    }
end

rsmfs.options.conditionally_show = function()
    local result = true

    if rsmfs.options.show_for_each_file then
        result = rsmfs.options.show()
    end

    return result
end

rsmfs.options.show = function()
    rsmfs.log("-------- Options")

    local vb = renoise.ViewBuilder()

    local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    local CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local DEFAULT_CONTROL_HEIGHT = renoise.ViewBuilder.DEFAULT_CONTROL_HEIGHT
    local TEXT_ROW_WIDTH = 140

    local add_checkbox = function(text, key, tooltip)
        return vb:row {
            vb:text {
                width = TEXT_ROW_WIDTH,
                text = text,
            },
            vb:checkbox {
                value = rsmfs.options[key],
                tooltip = tooltip,
                notifier = function(new_value)
                    rsmfs.log("%s = %s", text, tostring(new_value))
                    rsmfs.options[key] = new_value
                end,
            }
        }
    end

    local add_valuebox = function(text, key, min, max, tooltip)
        return vb:row {
            vb:text {
                width = TEXT_ROW_WIDTH,
                text = text
            },
            vb:valuebox {
                min = min,
                max = max,
                value = rsmfs.options[key],
                tooltip = tooltip,
                notifier = function(new_value)
                    rsmfs.log("%s = %s", text, tostring(new_value))
                    rsmfs.options[key] = new_value
                end,
            }
        }
    end

    local dialog_content = vb:column {
        margin = DIALOG_MARGIN,
        spacing = CONTENT_SPACING,

        vb:row {
            spacing = 4 * CONTENT_SPACING,

            vb:column {
                spacing = CONTENT_SPACING,

                add_checkbox("Add note columns", "add_note_columns", "Adds note columns to track if needed"),
                add_checkbox("Remove note columns", "remove_note_columns", "Removes note columns to track if needed"),
                add_checkbox("Increase number of lines", "increase_number_of_lines", "Increases pattern number of lines if needed"),
                add_checkbox("Decrease number of lines", "decrease_number_of_lines", "Decreases pattern number of lines if needed"),

                vb:space { height = DEFAULT_CONTROL_HEIGHT },

                add_checkbox("Include velocity", "include_velocity", "Includes note velocity (volume)"),
                add_checkbox("Include delay", "include_delay", "Includes note delay"),
                add_checkbox("Include note off", "include_note_off", "Includes note-off (OFF)"),

                vb:space { height = DEFAULT_CONTROL_HEIGHT },

                add_checkbox("Correct positions", "correct_positions", "Increase by 1 note's start or end positions if delay is higher than FD"),
                add_checkbox("Insert at cursor position", "insert_at_cursor", "Inserts notes at cursor position"),
                add_checkbox("Clear existing notes", "clear_existing_notes", "Clears existing notes before inserting new notes"),

                vb:space { height = DEFAULT_CONTROL_HEIGHT },

                add_valuebox("Resolution", "resolution", 1, 16, "Stretch notes by LPB * resolution / 4"),
                add_valuebox("Octave correction", "octave", -4, 4, "Transpose all notes by a number of octaves"),
                add_valuebox("Transposition", "transposition", -12, 12, "Transpose all notes by a number of semitones"),

                vb:space { height = DEFAULT_CONTROL_HEIGHT },

                add_checkbox("Show for each file", "show_for_each_file", "Show this options dialog for each loaded file")
            }
        }
    }

    local action = renoise.app():show_custom_prompt("Renoise Simple Midi File Support", dialog_content, { "OK", "Close" })
    rsmfs.log(action)
    return action == "OK"
end

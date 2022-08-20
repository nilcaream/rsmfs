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
}

rsmfs.options.init = function()
    renoise.tool():add_menu_entry {
        name = "Main Menu:Tools:Renoise Simple Midi File Support",
        invoke = rsmfs.options.show
    }
end

rsmfs.options.show = function(on_action)
    rsmfs.log("-------- Options")

    local vb = renoise.ViewBuilder()

    local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    local CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local CONTENT_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN
    local DEFAULT_CONTROL_HEIGHT = renoise.ViewBuilder.DEFAULT_CONTROL_HEIGHT
    local DEFAULT_DIALOG_BUTTON_HEIGHT = renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT
    local DEFAULT_MINI_CONTROL_HEIGHT = renoise.ViewBuilder.DEFAULT_MINI_CONTROL_HEIGHT
    local TEXT_ROW_WIDTH = 140

    local add_checkbox = function(text, value, on_change)
        return vb:row {
            vb:text {
                width = TEXT_ROW_WIDTH,
                text = text
            },
            vb:checkbox {
                value = value,
                notifier = function(new_value)
                    rsmfs.log("%s = %s", text, tostring(new_value))
                    if on_change ~= nil then
                        on_change(new_value)
                    end
                end,
            }
        }
    end

    local add_valuebox = function(text, value, min, max, on_change)
        return vb:row {
            vb:text {
                width = TEXT_ROW_WIDTH,
                text = text
            },
            vb:valuebox {
                min = min,
                max = max,
                value = value,
                notifier = function(new_value)
                    rsmfs.log("%s = %s", text, tostring(new_value))
                    if on_change ~= nil then
                        on_change(new_value)
                    end
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

                add_checkbox("Add note columns", rsmfs.options.add_note_columns, function(v)
                    rsmfs.options.add_note_columns = v
                end),
                add_checkbox("Remove note columns", rsmfs.options.remove_note_columns, function(v)
                    rsmfs.options.remove_note_columns = v
                end),
                add_checkbox("Increase number of lines", rsmfs.options.increase_number_of_lines, function(v)
                    rsmfs.options.increase_number_of_lines = v
                end),
                add_checkbox("Decrease number of lines", rsmfs.options.decrease_number_of_lines, function(v)
                    rsmfs.options.decrease_number_of_lines = v
                end),

                vb:space { height = DEFAULT_CONTROL_HEIGHT },

                add_valuebox("Resolution", rsmfs.options.resolution, 1, 16, function(v)
                    rsmfs.options.resolution = v
                end),
                add_valuebox("Octave correction", rsmfs.options.octave, -4, 4, function(v)
                    rsmfs.options.octave = v
                end),
                add_valuebox("Transposition", rsmfs.options.transposition, -4, 4, function(v)
                    rsmfs.options.transposition = v
                end),

                vb:space { height = DEFAULT_CONTROL_HEIGHT },

                add_checkbox("Show for each file", rsmfs.options.show_for_each_file, function(v)
                    rsmfs.options.show_for_each_file = v
                end),
            }
        }
    }

    local action = renoise.app():show_custom_prompt(
            "Renoise Simple Midi File Support", dialog_content, { "OK" }
    )

    rsmfs.log(action)

    if on_action ~= nil then
        on_action(action)
    end

    return action
end

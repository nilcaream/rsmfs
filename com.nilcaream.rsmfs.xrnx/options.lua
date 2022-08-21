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
}

rsmfs.options.init = function()
    renoise.tool():add_menu_entry {
        name = "Main Menu:Tools:Renoise Simple Midi File Support",
        invoke = rsmfs.options.configure_or_load
    }
end

rsmfs.options.configure = function()
    return rsmfs.options.show(false)
end

rsmfs.options.configure_or_load = function()
    return rsmfs.options.show(true)
end

rsmfs.options.show = function(include_load_file)
    rsmfs.log("-------- Options")

    local vb = renoise.ViewBuilder()

    local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    local CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local DEFAULT_CONTROL_HEIGHT = renoise.ViewBuilder.DEFAULT_CONTROL_HEIGHT
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
                add_checkbox("Include velocity", rsmfs.options.include_velocity, function(v)
                    rsmfs.options.include_velocity = v
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

                add_checkbox("Show for each .xrmid file", rsmfs.options.show_for_each_file, function(v)
                    rsmfs.options.show_for_each_file = v
                end),
            }
        }
    }

    local buttons

    if include_load_file == true then
        buttons = { "OK", "Select file", "Close" }
    else
        buttons = { "OK", "Close" }
    end

    local action = renoise.app():show_custom_prompt("Renoise Simple Midi File Support", dialog_content, buttons)

    rsmfs.log(action)

    if include_load_file == true and action == "Select file" then
        local filename = renoise.app():prompt_for_filename_to_read({ "mid", "xrmid" }, "Select midi file to load")
        if filename ~= nil and filename ~= "" then
            rsmfs.main.import(filename)
        end
    end

    return action
end

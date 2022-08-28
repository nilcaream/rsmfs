require("common")
require("options")
require("input-output")

rsmfs.main = {}

rsmfs.main.init = function()

    renoise.tool():add_menu_entry {
        -- right click on pattern track
        name = "Pattern Editor:Import midi file",
        invoke = rsmfs.io.select_and_load_midi_file
    }

    -- TODO disk browser does not provide a filename that the user has clicked on
    --renoise.tool():add_menu_entry {
    --    -- right click on file in disk browser
    --    name = "Disk Browser Files:Import midi file",
    --    invoke = -- TODO implement
    --}

    local integration = {
        category = "instrument",
        extensions = { "xrmid" },
        invoke = function(filename)
            if rsmfs.options.conditionally_show() == true then
                return rsmfs.io.load_midi_file(filename)
            end
        end
    }

    if renoise.tool():has_file_import_hook(integration.category, integration.extensions) == false then
        renoise.tool():add_file_import_hook(integration)
    else
        log("Import hook already present")
    end
end

-- =========================================

rsmfs.options.init()
rsmfs.main.init()

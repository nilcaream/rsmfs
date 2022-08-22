rsmfs = {}

rsmfs.log = function(s, ...)
    print("RSMFS " .. string.format(tostring(s), ...))
end

rsmfs.status = function(message)
    renoise.app():show_status(message)
    rsmfs.log(message)
end

rsmfs.log("Renoise Simple Midi File Support")

rsmfs = {}

rsmfs.log = function(s, ...)
    print("RSMFS " .. string.format(tostring(s), ...))
end

rsmfs.log("Renoise Simple Midi File Support")

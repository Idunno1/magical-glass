local lib = {}

function lib:init()
    if not Mod.libs["magical-glass"] then error("\"magical-glass\" library is missing.") end
end

return lib
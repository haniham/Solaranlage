-- Autor: Markus Hahnenkamm
-- Zur privaten, nicht kommeziellen Nutzung freigegeben.

print ("init.lua - waiting 5 seconds")

-- 5 Sekunden abwarten um eine Neuprogrammierung zu ermöglichen
tmr.alarm(0, 5000, 1, function()
    tmr.stop(0)
    print("Launching solaranlage.lua")
    dofile("solaranlage.lua")
end)

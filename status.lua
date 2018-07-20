-- To be included at the top of main, will trickle down into all other files
-- Functional? Yes.             Bad practice? Probably.

StatusText = ""
StatusTextTime = 0

function printst(str)
    print(str)
    StatusText = str
    StatusTextTime = 0
end

function updateStatusText(dt)
    StatusTextTime = StatusTextTime + dt
    if StatusTextTime > 2 and StatusText ~= '' then
        printst('')
    end
end

printst('App loaded')
local Textbox = {
    cursorTimer = 0,
    TEXT_BOX_CURSOR = "|",
    on = false,
    body = "",
    submitted = false
}

Textbox.clear = function()
    local ret = Textbox.body
    Textbox.on = false
    Textbox.body = ""
    Textbox.submitted = false
    return ret
end

Textbox.submit = function()
    -- Flags itself as submitted, someone else needs to listen for this and clear
    Textbox.submitted = true
end

Textbox.update = function(self, dt)
    self.cursorTimer = self.cursorTimer + dt
    if math.sin(self.cursorTimer * math.pi * 2) > 0 then
        self.cursor = "|"
    else
        self.cursor = ""
    end
end

Textbox.clear()

return Textbox

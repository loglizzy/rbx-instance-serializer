local actor: Actor = script.Parent
if not actor:IsA("Actor") then
    script.Enabled = false
    return
end

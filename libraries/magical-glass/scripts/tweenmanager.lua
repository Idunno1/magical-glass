local TweenManager = {}

TweenManager.__TWEENS = {}
TweenManager.__TWEENS_TO_REMOVE = {}

function TweenManager.tween(obj, prop, time, ease)
    local tween = {}
    tween.object = obj
    tween.properties = prop
    tween.init_properties = Utils.copy(tween.object)
    tween.time = time
    tween.easing = ease or "linear"

    tween.progress = 0
    tween.props_to_remove = {}

    table.insert(TweenManager.__TWEENS, tween)
end

function TweenManager.updateTweens()
    for _,tween in ipairs(TweenManager.__TWEENS) do
        tween.progress = tween.progress + DTMULT

        for prop, value in pairs(tween.properties) do
            tween.object[prop] = (Ease[tween.easing](tween.progress, tween.init_properties[prop], value - tween.init_properties[prop], tween.time))

            if tween.progress >= tween.time - 1 then
                tween.progress = tween.time - 1
                tween.object[prop] = value
                table.insert(tween.props_to_remove, prop)
            end

        end

    end
end

function TweenManager.updateTweensToRemove()
    for _,tween in ipairs(TweenManager.__TWEENS) do

        for _,prop in ipairs(tween.props_to_remove) do
            tween.properties[prop] = nil
        end

        local i = 0
        for prop, value in pairs(tween.properties) do
            if prop then
                i = i + 1
            end
        end

        if i == 0 then
            table.insert(TweenManager.__TWEENS_TO_REMOVE, tween)
        end
    end

    for _,tween in ipairs(TweenManager.__TWEENS_TO_REMOVE) do
        Utils.removeFromTable(TweenManager.__TWEENS, tween)
    end
end

Utils.hook(Game, "update", function(orig, self)
    orig(self)
    TweenManager.updateTweens()
    TweenManager.updateTweensToRemove()
end)

return TweenManager
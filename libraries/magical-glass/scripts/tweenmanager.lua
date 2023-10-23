local TweenManager = {}

TweenManager.__TWEENS = {}

function TweenManager.tween(obj, prop, time, ease)
    local tween = {}
    tween.object = obj
    tween.properties = prop
    tween.init_properties = Utils.copy(tween.object)
    tween.time = time
    tween.easing = ease or "linear"
    tween.speed = speed or 1

    tween.progress = 0

    for _,itween in ipairs(TweenManager.__TWEENS) do
        if itween.object == tween.object then
            Utils.removeFromTable(TweenManager.__TWEENS, itween)
        end
    end

    table.insert(TweenManager.__TWEENS, tween)
end

function TweenManager.updateTweens()
    for _,tween in ipairs(TweenManager.__TWEENS) do
        tween.progress = tween.progress + DTMULT

        for prop, value in pairs(tween.properties) do
            tween.object[prop] = (Ease[tween.easing](tween.progress, tween.init_properties[prop], value - tween.init_properties[prop], tween.time))

            if tween.progress >= tween.time then
                tween.progress = tween.time
                Utils.removeFromTable(TweenManager.__TWEENS, tween)
            end

        end

    end
end

Utils.hook(Game, "update", function(orig, self)
    orig(self)
    TweenManager.updateTweens()
end)

return TweenManager
local idleAnimation = 2;

local after = C_Timer.After;

TRP3_API.ui.argi={}
TRP3_API.ui.argi.animators = {};

local function registerFrameAnimation(frame)

    local _time = 0;
    local _duration, _fromx, _tox, _fromy, _toy, _fromz, _toz
    local _playAnimation = false;

    local function getPosition(percent)
        return
        _fromx + (_tox - _fromx) * percent,
        _fromy + (_toy - _fromy) * percent,
        _fromz + (_toz - _fromz) * percent;
    end

    local function animate(self, elapsed)
        if _playAnimation then
            if (_time > _duration) then
                -- animation is finished, move to end point and unregister the event
                frame:SetPosition(getPosition(1));
                frame:SetAnimation(idleAnimation);
                _playAnimation = false;
            else
                --move the animation
                frame:SetPosition(getPosition(_time / _duration));
            end
            _time = _time + elapsed;
        end
    end

    frame:SetScript("OnUpdate", animate);

    local function playAnimation(tox, toy, toz, duration, animation)
        _fromx, _fromy, _fromz = frame:GetPosition()
        _tox, _toy, _toz, _duration = tox, toy, toz, duration


        if (animation) then
            frame:SetAnimation(animation);
        end
        -- set the starting point

        _playAnimation = true;
        _time = 0;
    end

    TRP3_API.ui.argi.animators[frame:GetName()] = playAnimation
end

local function animateArrival(frame)
    frame:SetPosition(-10,-10,0);
    TRP3_API.ui.argi.animators[frame:GetName()](-8, -8, 1, 0.1, 37);
    after(0.1, function()
        TRP3_API.ui.argi.animators[frame:GetName()]( -5, -5, 2, 0.2, 38);
        after(0.2, function()
            TRP3_API.ui.argi.animators[frame:GetName()](-3, -3, 2, 0.1, 38);
            after(0.1, function()
                TRP3_API.ui.argi.animators[frame:GetName()](-1, -1, 1, 0.2, 38);
            end);
            after(0.2, function()
                TRP3_API.ui.argi.animators[frame:GetName()](0, 0, 0, 0.2, 39);
            end);
        end);
    end);
end
TRP3_API.ui.argi.registerFrameAnimation = registerFrameAnimation;
TRP3_API.ui.argi.animateArrival = animateArrival;
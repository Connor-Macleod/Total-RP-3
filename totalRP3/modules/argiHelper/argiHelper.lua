----------------------------------------------------------------------------------
-- Total RP 3
-- Argi Helper core
--	---------------------------------------------------------------------------
--	Copyright 2017 Saelora (mail@saelorable.com)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local idleAnimation = 0;

local after = C_Timer.After;


local function registerFrameForAnimation(frame)
    frame.currentAnimation = {};
    frame.animationQueue = {};
    local processAnimationQueue;

    local function getPosition(percent)
        return
        frame.currentAnimation.fromx + (frame.currentAnimation.tox - frame.currentAnimation.fromx) * percent,
        frame.currentAnimation.fromy + (frame.currentAnimation.toy - frame.currentAnimation.fromy) * percent,
        frame.currentAnimation.fromz + (frame.currentAnimation.toz - frame.currentAnimation.fromz) * percent;
    end

    local function animate(self, elapsed)
        if frame.currentAnimation.playAnimation then
            if (frame.currentAnimation.time > frame.currentAnimation.duration) then
                -- animation is finished, move to the next animation in the queue
                -- and turn playAnimation off so the animate finction stops triggering.
                frame.model:SetPosition(getPosition(1));
                frame.model:SetAnimation(idleAnimation);
                frame.currentAnimation.playAnimation = false;
                processAnimationQueue(true);
            else
                --move the animation
                frame.model:SetPosition(getPosition(frame.currentAnimation.time / frame.currentAnimation.duration));
            end
            frame.currentAnimation.time = frame.currentAnimation.time + elapsed;
        end
    end

    frame:SetScript("OnUpdate", animate);

    local function playAnimation(tox, toy, toz, duration, animation)
        frame.currentAnimation.fromx, frame.currentAnimation.fromy, frame.currentAnimation.fromz = frame.model:GetPosition()
        frame.currentAnimation.tox, frame.currentAnimation.toy, frame.currentAnimation.toz, frame.currentAnimation.duration = tox, toy, toz, duration


        if (animation) then
            frame.model:SetAnimation(animation);
        end

        frame.currentAnimation.playAnimation = true;
        frame.currentAnimation.time = 0;
    end

    local queueIsAnimating = false;
    processAnimationQueue = function(lastAnimationFinished)
        if lastAnimationFinished then
            queueIsAnimating = false;
        end
        if (frame.animationQueue[1] and not queueIsAnimating) then
            queueIsAnimating = true;
            if (type(frame.animationQueue[1]) == "number") then
                after(frame.animationQueue[1], function()
                    processAnimationQueue(true);
                end)
            else
                playAnimation(unpack(frame.animationQueue[1]));
            end
            table.remove(frame.animationQueue, 1);
        end
    end

    local function addAnimationToQueue(...)
        TRP3_API.utils.log.log("queing up Argi Animation");
        table.insert(frame.animationQueue, { ... });
        processAnimationQueue();
    end

    local function addDelayToQueue(time)
        frame.animationQueue.insert(time);
        processAnimationQueue();
    end

    local function clearQueue(setPositionx, setPositiony, setPositionz)
        frame.animationQueue = {};
        frame.currentAnimation.playAnimation = false;
        queueIsAnimating = false;
        local getPositionx, getPositiony, getPositionz = frame.model:GetPosition();
        frame.model:SetPosition(setPositionx or getPositionx, setPositiony or getPositiony, setPositionz or getPositionz);
    end

    frame.clearQueue = clearQueue;
    frame.addAnimation = addAnimationToQueue;
    frame.addAnimationDelay = addDelayToQueue;
    frame.animator = playAnimation;
end

local function initArgi()
    TRP3_API.utils.log.log("Starting Argi Helper initialisation");
    TRP3_API.ui.argi.animators = {};
    argiHelpFrame.model:SetDisplayInfo("61128");
    argiHelpFrame.model:InitializeCamera(1.1);
    argiHelpFrame.model:SetTargetDistance(0);
    argiHelpFrame.model:SetPosition(-10,-10,0);
    argiHelpFrame.model:SetFacing(math.pi / 4);
    registerFrameForAnimation(argiHelpFrame);
    TRP3_API.ui.argi.initHelpTree();
    TRP3_API.utils.log.log("Done Argi Helper initialisation");

end

TRP3_API.ui.argi = {};
TRP3_API.ui.argi.initArgi = initArgi;
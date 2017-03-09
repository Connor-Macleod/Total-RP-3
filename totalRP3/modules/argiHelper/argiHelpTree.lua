----------------------------------------------------------------------------------
-- Total RP 3
-- Argi Helper help tree
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

local after = C_Timer.After;

local function setupArgiHelpTree(argiFrame)
    local argiHelpTree = {

    }


    local function argiHelpTreeRegisterNode(node)
        TRP3_API.utils.log.log("Registering Argi Helper Tree node: "..node.id);
        local function handleNode()
            TRP3_API.utils.log.log("Handling Argi Helper Tree node "..node.id.." on event "..node.event);
            if node.beforeDisplay then
                TRP3_API.utils.log.log("Triggering Argi pre-show function");
                node.beforeDisplay(node, argiFrame);
            end
            function contiune()
                node.run = node.run + 1;
                local message = node.message;
                if node.run==1 then
                    message = node.showFirst_message;
                end
                argiFrame.speech.text:SetText(message);
                argiHelpFrame.speech:SetHeight(argiHelpFrame.speech.text:GetHeight() + 30);
                argiHelpFrame.speech:SetWidth(argiHelpFrame.speech.text:GetWidth() + 30);
                if node.onDisplay then
                    node.onDispay();
                end
                argiHelpFrame.speech:Show();
                if node.duration then
                    after(node.duration, function()
                        if (argiFrame.speech.text:GetText()==message) then
                            if node.onExpiry then
                                node.onExpiry();
                            end
                            argiHelpFrame.speech:Hide();
                            argiFrame.speech.text:SetText("");
                        end
                    end)
                end
            end
            if node.delay then
                after(node.delay, contiune);
            else
                continue();
            end

        end

        local event = node.event;
        fields = {};
        for field in event:gmatch("[^_]+") do
            table.insert(fields, field);
        end
        if fields[1] == "ARGI" then
            if fields[2]=="FRAME" then
                if fields[3]=="SHOW" then
                    TRP3_API.utils.log.log("Registering Argi Helper Tree event "..event.." for node "..node.id);
                    argiFrame:SetScript("OnShow", handleNode);
                end
            end
        end
        node.run = 0;
        argiHelpTree[node.id] = node;

    end

    argiFrame:SetScript("OnHide", function()
        argiHelpFrame.speech:Hide();
        argiFrame.speech.text:SetText("");
    end)

    return {
        registerNode = argiHelpTreeRegisterNode,
    }
end

local function initArgiHelpTree()

    TRP3_API.utils.log.log("Starting Argi Helper Tree initialisation");
    TRP3_API.ui.argi.helpTree = setupArgiHelpTree(argiHelpFrame);

    local registerNode = TRP3_API.ui.argi.helpTree.registerNode;

    registerNode( {
        showFirst_message =  "Hi! I'm Argi!|n|nand I'm here to help you use my favouritest addon in the world, TRP3!",
        message = "Welcome back!",
        event = "ARGI_FRAME_SHOW",
        duration = 30,
        delay = 0.9,
        beforeDisplay = function(self, frame)
            frame.clearQueue(-10, -10, 0);
            frame.addAnimation(-8, -8, 1, 0.1, 37);
            frame.addAnimation(-5, -5, 2, 0.2, 38);
            frame.addAnimation(-3, -3, 2, 0.1, 38);
            frame.addAnimation(-1, -1, 1, 0.2, 38);
            frame.addAnimation(0, 0, 0, 0.2, 39);
        end,
        id = "ARGI_INTRO"
    });
    TRP3_API.utils.log.log("Done Argi Helper Tree initialisation");
end

TRP3_API.ui.argi.initHelpTree = initArgiHelpTree;

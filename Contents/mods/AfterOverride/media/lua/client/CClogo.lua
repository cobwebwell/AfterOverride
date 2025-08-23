local hdLogoScale = 4
local hdLogoPath = "media/ui/PZLogo.png"
------------------------------------------

function MainScreen:prerender()

	ISPanel.prerender(self);
    if(self.inGame) then
        self:drawRect(0, 0, self.width, self.height, 0.5, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    end
    if self.delay > 0 then
        if self.firstFrame then
            self.delay = self.delay - UIManager.getMillisSinceLastRender()
        else
            self.firstFrame = true
        end
    end
    local textManager = getTextManager();

    self.time = self.time + ((1.0 / 60)*getGameTime():getMultiplier());

    local lastIsSameTitle = false;
    local nextIsSameTitle = false;

    if self.time > 11.8 then
        if self.credits:size() > self.creditsIndex then
            if self.creditsIndex > 0 then
                if self.credits:get(self.creditsIndex-1).title == self.credits:get(self.creditsIndex).title then
                    lastIsSameTitle = true;
                end
            end

            if self.credits:size()-1 > self.creditsIndex then
                if self.credits:get(self.creditsIndex+1).title == self.credits:get(self.creditsIndex).title then
                    nextIsSameTitle = true;
                end
            end
        end
        local del = self.creditTime / self.creditTimeMax;
        local credAlpha = self.creditTime / self.creditTimeMax;
        if(credAlpha <= 0.5) then
            credAlpha = credAlpha * 2;
        elseif (credAlpha >= 0.8) then
            credAlpha = 1.0 - ((credAlpha - 0.8) * 5);
        else
            credAlpha = 1;
        end
        local credAlpha2 = self.creditTime / self.creditTimeMax;
        if(credAlpha2 <= 0.1) then
            credAlpha2 = credAlpha2 * 10;
            if lastIsSameTitle then credAlpha2 = 1; end
        elseif (credAlpha2 >= 0.9) then
            credAlpha2 = 1.0 - ((credAlpha2 - 0.9) * 10);
            if nextIsSameTitle then credAlpha2 = 1; end
        else
            credAlpha2 = 1;
        end

        self.creditTime = self.creditTime +  ((1.0 / 60)*getGameTime():getMultiplier());
        if self.creditTime > self.creditTimeMax then
            self.creditTime = 0;
            self.creditsIndex = self.creditsIndex + 1;
        end
        if self.credits:size() > self.creditsIndex and not self.inGame and ISDemoPopup.instance == nil then
            textManager:DrawString(UIFont.Cred1, (getCore():getScreenWidth()*0.75)+50 , getCore():getScreenHeight()*0.1, self.credits:get(self.creditsIndex).title, 1, 1, 1, credAlpha2);

            local x = (getCore():getScreenWidth()*0.75);
            local xwid = textManager:MeasureStringX(UIFont.Cred2, self.credits:get(self.creditsIndex).name);
            if(x + xwid > getCore():getScreenWidth()) then
               x = x - ((x + xwid) - getCore():getScreenWidth()) - 10;
            end
            textManager:DrawString(UIFont.Cred2, x, (getCore():getScreenHeight()*0.1) + 26, self.credits:get(self.creditsIndex).name, 1, 1, 1, credAlpha);
        end

    end

    local mainScreen = MainScreenState.getInstance();
	if mainScreen ~= nil and (ISDemoPopup.instance == nil) then
        local x = 50;
        local y = 50;
        local sw = getCore():getScreenWidth();

        local tex = self.logoTextureHD ----------------------------------------
        local w = tex:getWidth() / hdLogoScale; ----------------------------------------
        local h = tex:getHeight() / hdLogoScale; ----------------------------------------
        local resdelta = math.min(self:calcLogoHeight() / h, sw / 1920)
        x = x * (sw / 1920);
        y = y * (sw / 1920);
        w = w * resdelta;
        h = h * resdelta;
        self:drawTextureScaled(tex, x, y, w, h, 1-(self.warningFade / self.warningFadeMax), 1, 1, 1.0);
        if getDebug() and getDebugOptions():getBoolean("UI.Render.Outline") then
            self:drawRectBorder(x, y, w, h, 1, 1, 1, 1)
        end

        self.warningFade = self.warningFade - ((1.5 / 60)*getGameTime():getMultiplier());

        if self.warningFade < 0 then self.warningFade = 0; end

        local maxWidth = math.max(w / 2, self.maxMenuItemWidth)
        for _,child in pairs(self.bottomPanel:getChildren()) do
            if child.Type == "ISLabel" then
                child:setWidth(maxWidth)
            end
        end
        self.bottomPanel:setWidth(maxWidth)
        self.bottomPanel:setX(x + (w - self.bottomPanel:getWidth()) / 2)
        self.bottomPanel:setY(x + h + 50 * (sw / 1920))
	end

    if isDemo() and not self.inGame then
        if self.bottomPanel:getIsVisible() then
            if not self.demoMessagePanel then
                local y = self.bottomPanel:getY() - 35 * 3
                self.demoMessagePanel = ISRichTextPanel:new(self.width / 2 - 800 / 2, 0, 800, 35 * 3)
                self.demoMessagePanel:setAnchorTop(false)
                self.demoMessagePanel:setAnchorBottom(true)
                self.demoMessagePanel.font = UIFont.Medium
                self:addChild(self.demoMessagePanel)
                self.demoMessagePanel.text = getText("UI_Demo_Welcome")
                self.demoMessagePanel:paginate()
            end
            self.demoMessagePanel:setX(self.width / 2 - self.demoMessagePanel:getWidth() / 2)
            self.demoMessagePanel:setY(self.bottomPanel:getY() - 24 - self.demoMessagePanel:getHeight())
        end
        if self.demoMessagePanel then
            self.demoMessagePanel:setVisible(self.bottomPanel:getIsVisible())
        end
    end
end

function MainScreen:new (inGame)
	-- using a virtual 100 height res for doing the UI, so it resizes properly on different rez's.
	MainScreen.StaticHeight = 100;
	MainScreen.StaticWidth = MainScreen.StaticHeight * 1.7777777;
	local o = {}

	--o.data = {}
	o = ISPanelJoypad:new(0, 0, MainScreen.StaticWidth, MainScreen.StaticHeight);
	setmetatable(o, self)
	self.__index = self
	o.x = 0;
	o.y = 0;
	o.backgroundColor = {r=0, g=0, b=0, a=0.0};
	o.borderColor = {r=1, g=1, b=1, a=0.0};

	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
    o.warningFadeMax = 10;
    o.warningFade = o.warningFadeMax;
    o.credits = LuaList:new();
    o.creditsIndex = 0;
    o.delay = inGame and -1 or 500 -- milliseconds
    o.firstFrame = false
    o.creditTimeMax = 7;
    o.creditTime = 0;
    o:doCredits();
    o.time = 0;
    o.inGame =inGame;

    useTextureFiltering(true)
	o.logoTexture = getTexture("media/ui/PZLogoTexture.png")
    o.logoTextureHD = getTexture(hdLogoPath) ----------------------------------------
    useTextureFiltering(false)
 
    MainScreen.instance = o;
    MainScreenInstance = o;
    return o
end

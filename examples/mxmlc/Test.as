package {
    import flash.display.*;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.events.MouseEvent;
    import mochi.as3.*;

    import flash.events.Event;
    import flash.events.IOErrorEvent;

    // The clip that MochiAd uses must be dynamic
    public dynamic class Test extends MovieClip {

        public static var GAME_OPTIONS:Object = {id: "test", res:"550x400"};

        [Embed(source="assets/MochiAds_Logo.swf")]
        private var Logo:Class;

        private var sectionTitle:TextField;
        private var logo:DisplayObject;
        private var body:MovieClip;
        private var clickAwayAdMC:MovieClip;

        private var _playerName:String;
        private var _playerScore:Number;

        private var _storeItems:Object;
        private var _item:String;

        private var _loginEvent:Object;

        public function Test() {
            super();
            // This initializes if the preloader is turned off.
            if (stage != null) {
                init(false);
            }
        }

        public function init(did_load:Boolean):void {
            MochiServices.connect("84993a1de4031cd8", root);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            mouseChildren = true;
            placeLogo();
            showMainMenu();
            setSectionTitle("MochiAd " + MochiAd.getVersion() + " Demo");

            MochiSocial.addEventListener(MochiSocial.ERROR, coinsError);
            MochiSocial.addEventListener(MochiSocial.LOGGED_IN, onLogin);
            MochiSocial.addEventListener(MochiSocial.LOGGED_OUT, onLogout);
            MochiCoins.addEventListener(MochiCoins.ITEM_OWNED, coinsEvent);
            MochiCoins.addEventListener(MochiCoins.STORE_ITEMS, storeItems);

            MochiCoins.getStoreItems();
            MochiSocial.showLoginWidget( { x:330, y:360 } );

            MochiInventory.addEventListener(MochiInventory.READY, inventoryReady );
            MochiInventory.addEventListener(MochiInventory.WRITTEN, inventorySynced );
        }

        private function inventoryReady(status:Object):void {
            trace("INVENTORY READY!");
            trace("INVENTORY MONEY: ", MochiCoins.inventory.money );

            if( !MochiCoins.inventory.money )
                MochiCoins.inventory.money = 50;
            else
                MochiCoins.inventory.money += 50;

            trace("INVENTORY MONEY: ", MochiCoins.inventory.money );
        }

        private function inventorySynced(status:Object):void
        {
            trace( "Inventory synced" );
        }

        private function userDataFetch(result:MochiUserData):void {
            if (result.error != null) {
                trace("[GAME] [userDataFetch] error: " + result);
                return;
            }
            trace("[GAME] [userDataFetch] load_count = " + result.data);
            var counter:Number;
            if (result.data === null) {
                /* fetching a non-existent key will return null */
                counter = 0;
            } else {
                counter = result.data;
            }
            counter += 1;
            MochiUserData.put("load_count", counter, userDataPut);
        }

        private function userDataPut(result:MochiUserData):void {
            if (result.error != null) {
                trace("[GAME] [userDataPut] error: " + result);
                return;
            }
            trace("[GAME] [userDataPut] success: " + result);
        }

        private function coinsError(error:Object):void {
            trace("[GAME] [coinsError] " + error.type);
        }

        private function coinsEvent(event:Object):void {
            trace("[GAME] [coinsEvent] " + event);
        }

        private function onLogin(event:Object):void {
            loginEvent = event;
            MochiUserData.get("load_count", userDataFetch);
            MochiSocial.saveUserProperties({ hitPoints: 120 });
        }

        private function onLogout(event:Object):void {
            loginEvent = null;
        }

        private function get loginEvent():Object {
            return _loginEvent;
        }

        private function set loginEvent(event:Object):void {
            _loginEvent = event;
            var txt:String;
            if (_loginEvent) {
                // logged in
                txt = "name: " + _loginEvent.name;
            } else {
                // logged out
                txt = "not logged in";
            }
            try {
                var s:Sprite = Sprite(body.getChildByName("MochiSocial.LOGGED_IN"));
                var subtitle:TextField = TextField(s.getChildByName("subtitle"));
                subtitle.text = txt;
            } catch (e:Error) {
                /* not initialized yet */
            }
        }

        private function storeItems(arg:Object):void {
            _storeItems = arg;
            for (var i:String in _storeItems) {
                trace("[GAME] [StoreItems] " + _storeItems[i]);
                _item = _storeItems[i].id;
            }
        }

        private function onLeaderboardError(status:String):void {
            trace("[GAME] Leaderboard onError called " + status);
        }

        public function showLeaderboard(ev:Object=null):void {
            MochiScores.showLeaderboard({boardID: "1e113c7239048b3f", res: "550x400", clip: this});
        }

        public function submitScore(ev:Object=null):void {
            var score:MochiDigits = new MochiDigits();

            score.setValue(0);
            score.addValue(1000);
            score.addValue(int(Math.random() * 500));

            MochiScores.showLeaderboard({boardID: "1e113c7239048b3f", res: "550x400", clip: this, score:score.value});
        }

        private function showInterLevel(ev:Object=null):void {
            clearSection();
            setSectionTitle("MochiAd Demo: showInterLevelAd");

            var opts:Object = getOptions();
            opts.ad_started = function ():void {};
            opts.ad_finished = showMainMenu;
            MochiAd.showInterLevelAd(opts);
        }

        private function showClickAway(ev:Object=null):void {
            clearSection();
            setSectionTitle("MochiAd Demo: showClickAwayAd");

            clickAwayAdMC = new MovieClip();
            clickAwayAdMC.x = 0;
            clickAwayAdMC.y = 20;
            body.addChild(clickAwayAdMC);

            var unloadButton:Sprite = newMenuButton("Main Menu", "", unloadClickAway);
            unloadButton.x = 360;
            unloadButton.y = 120;
            clickAwayAdMC.addChild(unloadButton);

            var opts:Object = {id: "test",
                               clip: clickAwayAdMC};

            MochiAd.showClickAwayAd(opts);
        }

        public function unloadClickAway(ev:Object=null):void {
            MochiAd.unload(clickAwayAdMC);
            body.removeChild(clickAwayAdMC);
            showMainMenu();
        }

        private function showStore(ev:Object = null):void {
            MochiCoins.showStore({});
        }

        private function showItem(ev:Object = null):void {
            MochiCoins.showItem({item: _item});
        }

        private function showLogin(ev:Object = null):void {
            MochiSocial.showLoginWidget({x:330, y:360});
        }

        private function hideLogin(ev:Object = null):void {
            MochiSocial.hideLoginWidget()
        }


        public function showMainMenu(ev:Object=null):void {
            clearSection();
            setSectionTitle("MochiAd " + MochiAd.getVersion() + " Demo");


            var menuTitle:TextField = new TextField();
            menuTitle.selectable = false;
            menuTitle.autoSize = TextFieldAutoSize.CENTER;
            menuTitle.y = 100 - body.y;
            menuTitle.x = 0.5 * stage.stageWidth;
            menuTitle.defaultTextFormat = menuTextFormat("heading");
            menuTitle.text = "Choose one of the functions below to demonstrate it in action";
            body.addChild(menuTitle);

            var menuItems:Array = [
                ["showInterLevelAd", "10 second inter-level ad", showInterLevel],
                ["showClickAwayAd", "Show an click-away ad", showClickAway],
                ["showLeaderboard", "Show an example leaderboard", showLeaderboard],
                ["submitScore", "Submit a score", submitScore],
                ["MochiSocial.LOGGED_IN", "", null]
            ];

            var menuItems2:Array = [
                ["showStore", "Show game store", showStore],
                ["showItem", "Show single item", showItem],
                ["showLogin", "Show login", showLogin],
                ["hideLogin", "Hide login", hideLogin],
            ];

            showColumn(menuTitle.x, menuTitle.y + menuTitle.height + 15, menuItems);
            showColumn(menuTitle.x + 285, menuTitle.y + menuTitle.height + 15, menuItems2);

            loginEvent = _loginEvent;
        }

        private function showColumn(x:Number, y:Number, menu:Array):void {
            var m_x:Number = x;
            var m_y:Number = y;
            for each (var menuItem:Array in menu) {
                var m:Sprite = newMenuButton(menuItem[0], menuItem[1], menuItem[2]);
                m.name = menuItem[0];
                m.x = m_x;
                m.y = m_y;
                m_y += m.height + 3;
                body.addChild(m);
            }
        }

        public function getOptions():Object {
            var opts:Object = {clip: this};
            for (var k:String in GAME_OPTIONS) {
                opts[k] = GAME_OPTIONS[k];
            }
            return opts;
        }

        public function newMenuButton(title:String, subtitle:String, callback:Function):Sprite {
            var s:Sprite = new Sprite();

            var titleField:TextField = new TextField();
            titleField.selectable = false;
            titleField.autoSize = TextFieldAutoSize.LEFT;
            titleField.defaultTextFormat = menuTextFormat("big");
            titleField.text = title;
            titleField.name = "title";
            s.addChild(titleField);

            var subtitleField:TextField = new TextField();
            subtitleField.selectable = false;
            subtitleField.autoSize = TextFieldAutoSize.LEFT;
            subtitleField.defaultTextFormat = menuTextFormat("small");
            subtitleField.text = subtitle;
            subtitleField.x = 24;
            subtitleField.y = titleField.height;
            subtitleField.name = "subtitle";
            s.addChild(subtitleField);

            if (callback !== null) {
                var hitSprite:Sprite = new Sprite();
                hitSprite.graphics.beginFill(0xCCFF00);
                hitSprite.graphics.drawRect(0, 0,
                    Math.max(titleField.x + titleField.width,
                            subtitleField.x + subtitleField.width),
                    Math.max(titleField.y + titleField.height,
                            subtitleField.y + subtitleField.height));
                s.hitArea = hitSprite;
                hitSprite.visible = false;
                s.addChild(hitSprite);

                s.buttonMode = true;
                s.mouseChildren = false;
                s.addEventListener(MouseEvent.CLICK, callback);
            }

            s.x = x;
            s.y = y;
            return s;

        }

        private function menuTextFormat(kind:String):TextFormat {
            var fmt:TextFormat = new TextFormat();
            fmt.font = "_sans";
            fmt.align = TextFormatAlign.LEFT;
            fmt.color = 0xffffff;
            fmt.size = 14;
            if (kind == "section") {
                fmt.align = TextFormatAlign.CENTER;
            } else if (kind == "small") {
            } else if (kind == "big") {
                fmt.color = 0x000000;
                fmt.size = 18;
            } else if (kind == "heading") {
                fmt.align = TextFormatAlign.CENTER;
                fmt.size = 18;
            } else {
                throw new Error("Invalid text format " + kind);
            }
            return fmt;
        }

        public function placeReturnButton():void {
            var s:Sprite = new Sprite();
            var titleField:TextField = new TextField();
            titleField.selectable = false;
            titleField.autoSize = TextFieldAutoSize.LEFT;
            titleField.defaultTextFormat = menuTextFormat("small");
            titleField.text = "(main menu)";
            s.addChild(titleField);

            var hitSprite:Sprite = new Sprite();
            hitSprite.graphics.beginFill(0xCCFF00);
            hitSprite.graphics.drawRect(0, 0, titleField.width, titleField.height);
            s.hitArea = hitSprite;
            hitSprite.visible = false;
            s.addChild(hitSprite);

            s.x = stage.stageWidth - s.width - 10;
            s.y = stage.stageHeight - s.height - 10 - body.y;
            s.buttonMode = true;
            s.mouseChildren = false;
            s.addEventListener(MouseEvent.CLICK, showMainMenu);
            body.addChild(s);
        }

        public function callback(s:Object):void {
        }

        private function clearSection():void {
            placeLogo();
            setSectionTitle("");
            if (body) {
                removeChild(body);
                body = null;
            }
            body = new MovieClip();
            body.y = sectionTitle.y + sectionTitle.height + 5;
            addChild(body);
        }

        private function setSectionTitle(title:String):void {
            if (sectionTitle == null) {
                sectionTitle = new TextField();
                sectionTitle.selectable = false;
                sectionTitle.autoSize = TextFieldAutoSize.CENTER;
                sectionTitle.y = logo.height + 5;
                sectionTitle.x = 0.5 * stage.stageWidth;
                sectionTitle.defaultTextFormat = menuTextFormat("section");
                addChild(sectionTitle);
            }
            sectionTitle.text = title;
        }

        private function placeLogo():void {
            if (logo == null) {
                logo = new Logo();
                logo.x = 0.5 * (stage.stageWidth - logo.width);
                addChild(logo);
            }
        }


    }

}

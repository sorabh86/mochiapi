import mochi.as2.*;

class Test {
    public static var GAME_ID:String = "test";
    public static var GAME_RES:String = "550x400";
    /* LEADERBOARD_GAME_ID should normally be the same as GAME_ID, but the
       "test" game does not implement the demo leaderboard */
    public static var LEADERBOARD_GAME_ID:String = "84993a1de4031cd8";
    /* It's not recommended to have this as a constant, you should use
       the code provided by mochiads.com, which is obfuscated and
       evaluated at runtime to make it harder to find the boardID.
       If you leave it as a string like this then it is much easier
       to insert fake scores. */
    public static var LEADERBOARD_BOARD_ID:String = "1e113c7239048b3f";


    static function begin(didLoad:Boolean) {
        var clickAwayMC:MovieClip = _root.createEmptyMovieClip("clickAwayMC",
            _root.getNextHighestDepth());

        var interlButton:MovieClip = newButton(10, 10, "Show Interlevel Ad");
        var clickAwayButton:MovieClip = newButton(10, 50, "Show clickAway Ad");
        var unloadButton:MovieClip = newButton(10, 50, "Unload clickAway Ad");
        var leaderboardButton:MovieClip = newButton(10, 90, "Show Leaderboard");
        var storeButton:MovieClip = newButton(10, 130, "Show Store");
        var itemButton:MovieClip = newButton(10, 170, "Show Item");
        var showLoginButton:MovieClip = newButton(10, 210, "Show Login");
        var hideLoginButton:MovieClip = newButton(10, 250, "Hide Login");
        var startRoundButton:MovieClip = newButton(10, 290, "Start Round");
        var endRoundButton:MovieClip = newButton(10, 330, "End Round");
        var trackEventButton:MovieClip = newButton(10, 370, "Track Event");



        MochiServices.connect(Test.LEADERBOARD_GAME_ID, _root);


        interlButton.onRelease = function() {
            MochiAd.showTimedAd({
                id: Test.GAME_ID,
                res: Test.GAME_RES,
                ad_loaded: function():Void {
                    interlButton._visible = false;
                    clickAwayButton._visible = false;
                },
                ad_finished: function():Void {
                    interlButton._visible = true;
                    if (!unloadButton._visible) {
                        clickAwayButton._visible = true;
                    }
                }
            });
        }

        clickAwayButton.onRelease = function() {
            clickAwayMC._x = 160;
            clickAwayMC._y = 10;
            MochiAd.showClickAwayAd({
                clip: clickAwayMC,
                id: Test.GAME_ID,
                ad_loaded: function():Void {
                }
            });
            clickAwayButton._visible = false;
            unloadButton._visible = true;
        }

        unloadButton._visible = false;
        unloadButton.onRelease = function() {
            MochiAd.unload(clickAwayMC);
            unloadButton._visible = false;
            clickAwayButton._visible = true;
        }

        leaderboardButton.onRelease = function ():Void {

            var score = new MochiDigits();

            score.setValue(0);
            score.addValue( 1000 );
            score.addValue( int(Math.random() * 500) );

            MochiScores.showLeaderboard({
                boardID: Test.LEADERBOARD_BOARD_ID,
                res: Test.GAME_RES,
                clip: _root,
                score: score.value
            });
        }

        storeButton.onRelease = function ():Void {
            MochiCoins.showStore({});
        }

        itemButton.onRelease = function():Void {
            MochiCoins.showItem({item: "7eb8d3ef7793239b"});
        }

        showLoginButton.onRelease = function():Void {
            MochiSocial.showLoginWidget({x:330, y:360});
        }

        hideLoginButton.onRelease = function():Void {
            MochiSocial.hideLoginWidget();
        }

        startRoundButton.onRelease = function():Void {
            MochiServices.startRound('levelTag');
        }

        endRoundButton.onRelease = function():Void {
            MochiServices.endRound();
        }

        var buttonHits:Number = 0;
        trackEventButton.onRelease = function():Void {
            MochiServices.trackEvent('button_hit', ++buttonHits);
        }

        MochiSocial.addEventListener(MochiSocial.ERROR, function (ev:Object):Void { Test.coinsError(ev); });
        MochiSocial.addEventListener(MochiSocial.LOGGED_IN, function (ev:Object):Void { Test.onLogin(ev); });
        MochiCoins.addEventListener(MochiCoins.ITEM_OWNED, function (ev:Object):Void { Test.coinsEvent(ev); });
        MochiCoins.addEventListener(MochiCoins.STORE_ITEMS, function (ev:Object):Void { Test.storeItems(ev); });

        MochiCoins.getStoreItems();
        MochiSocial.showLoginWidget({x:330, y:360});
    }

    public static function coinsError(error:Object):Void {
        trace("[GAME] [coinsError] " + error.type);
    }
    public static function coinsEvent(ev:Object):Void {
        trace("[GAME] [coinsEvent] " + ev);
    }
    public static function onLogin(ev:Object):Void {
        trace("[ON LOGIN   ]")
        MochiSocial.saveUserProperties({ hitPoints: 150 });
        trace("[GAME] [userProperties] " + ev.userProperties.hitPoints);
    }
    public static function storeItems(arg:Object):Void {
        var _storeItems:Object = arg;
        for (var i:String in _storeItems) {
            trace("[GAME] [StoreItems] " + _storeItems[i]);
            var _item:Object = _storeItems[i].id;
        }
    }

    static function newButton(x:Number, y:Number, label:String):MovieClip {
        var button = _root.createEmptyMovieClip(label, _root.getNextHighestDepth());

        var bTextFormat:TextFormat = new TextFormat();
        bTextFormat.align = "center";
        bTextFormat.font = "Tahoma";
        bTextFormat.size = 13;
        bTextFormat.color = 0x000000;

        button._x = x;
        button._y = y;
        button.lineStyle(0, 0x000000, 100, true, "none", "square", "round");
        button.lineTo(125, 0);
        button.lineTo(125, 30);
        button.lineTo(0, 30);
        button.lineTo(0, 0);
        button.createTextField("labelText", button.getNextHighestDepth(), 0, 5, button._width, 24);
        button.labelText.text = label;
        button.labelText.selectable = false;
        button.labelText.antiAliasType = "advanced";
        button.labelText.setTextFormat(bTextFormat);
        button._visible = true;

        return button;

    }

    static function main():Void {
        var did_load = false;
        MochiAd.showPreGameAd({
            id: Test.GAME_ID,
            res: Test.GAME_RES,
            clip: _root,
            ad_started: function ():Void {
                // this would otherwise call clip.stop();
            },
            ad_loaded: function ():Void {
                did_load = true;
            },
            ad_finished: function ():Void {
                Test.begin(did_load);
            }/*,
            skip: true
            */
        });
    }

}

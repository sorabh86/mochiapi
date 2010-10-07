
/**
 * Sample Game
 * This is a sample game that utilizes MochiServices
 * Be sure to place the mochi folder in the classpath of your game
 */

package {

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.TextField;
    import flash.display.SimpleButton;

    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.events.ProgressEvent;
    import flash.utils.getTimer;

    import mochi.as3.*;

    public dynamic class demo_as3 extends MovieClip {

        public var playerName:String;
        public var boardID:String;
        public var score:MochiDigits;

        public var lastPlayerName:String;
        public var lastScore:Number;

        private var _startTime:Number;
        private var _gameTime:Number;
        private var _storeItems:Object;

        private var _timer:Timer;

        //
        //
        public function demo_as3 () {

            this.loaderInfo.addEventListener(ProgressEvent.PROGRESS, checkLoaded);
            stop();
        }

        //
        //
        public function checkLoaded(theProgress:ProgressEvent):void {

            var percent:Number = Math.ceil((theProgress.bytesLoaded / theProgress.bytesTotal )*100 );

            if (percent == 100) {
                gotoAndPlay("connect");
            }

        }


        /**
         * Method: connectServices
         * Connects sample game to MochiServices
         * This is called in a frame of the root timeline before the game starts
         * @param    gameID
         */
        public function connectServices (gameID:String):void {

            MochiServices.connect(gameID, root);
            MochiAd.showPreGameAd({id:"84993a1de4031cd8", res: "550x400", clip:root});

            MochiCoins.addEventListener(MochiCoins.ERROR, coinsError);
            MochiSocial.addEventListener(MochiSocial.LOGGED_IN, coinsEvent);
            MochiCoins.addEventListener(MochiCoins.ITEM_OWNED, coinsEvent);
            MochiCoins.addEventListener(MochiCoins.STORE_ITEMS, storeItems);
        }

        /**
         * Method: init
         * Initializes the sample game
         * Notice that the boardID for this game is set here.
         */
        private function init ():void {

            boardID = "a4b4d5eab22720b4";

            MochiCoins.getStoreItems();
            MochiScores.setBoardID(boardID);

            var f =function() { trace("ACHIEVEMENT RECEIVED!"); };
            MochiEvents.addEventListener( MochiEvents.ACHIEVEMENT_RECEIVED, f );
//            MochiEvents.removeEventListener( MochiEvents.ACHIEVEMENT_RECEIVED, f );
            MochiEvents.startSession(boardID);

            playerName = "";
            score = new MochiDigits();

            mainMenu();
        }

        //
        //
        public function mainMenu ():void {

            gotoAndPlay("game menu");

            MochiSocial.showLoginWidget({x:36+10, y:340-14});

            var myClip:MovieClip = root["myscores"];
            trace("my clip: " + myClip);
            //MochiAd.showInterLevelAd( { clip: myClip, id:"84993a1de4031cd8", res:"470x320", ad_finished: function ():void { trace("ad finished!"); } } );
            // getScoreData();

        }

        public function onRequest (args:Object):void {

            trace("scores received!");

        }

        private function coinsEvent(event:Object):void {
            trace("[GAME] [coinsEvent] " + event);
        }

        private function coinsError(error:Object):void {
            trace("[GAME] [coinsError] " + error.type);
        }

        private function storeItems(arg:Object):void {
            _storeItems = arg;
            for (var key:String in _storeItems)
                trace("[GAME] [StoreItems] " + key);
        }
        //
        //
        public function setMenuCallbacks ():void {
            root["dialogue_login"].visible = false;
            root["dialogue_instructions"].visible = false;

            root["btn_name"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.showLogin();
                });

            root["btn_buy"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    MochiCoins.showStore({});
                });

            root["dialogue_login"]["btn_submit"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.parent.playerName = e.currentTarget.parent.username.text;
                    e.currentTarget.parent.visible = false;
                });

            root["dialogue_login"]["username"].addEventListener(TextEvent.TEXT_INPUT,
                function (e:TextEvent) {
                    if (e.text != null) {
                        if (e.text.indexOf("\n") != -1) {
                            var name:String = e.target.text;
                            e.preventDefault();
                            root["dialogue_login"].visible = false;
                            e.currentTarget.parent.parent.playerName = name;
                        }
                    }
                });

            root["btn_start"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.playGame();
                });

            root["btn_instructions"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent["dialogue_instructions"].visible = true;
                });

            root["dialogue_instructions"]["btn_close"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.visible = false;
                });

            root["btn_scores"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.showScores();
                });

        }

        //
        //
        public function setGameOverCallbacks ():void {

            root["btn_submitscore"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.submitScore();
                });

            root["btn_menu"].addEventListener(MouseEvent.MOUSE_UP,
                function (e:MouseEvent) {
                    e.currentTarget.parent.mainMenu();
                });

        }

        //
        //
        public function playGame (e:Event = null):void {
            MochiSocial.hideLoginWidget()
            gotoAndStop("game play");
        }

        //
        //
        public function showLogin ():void {
            root["dialogue_login"].username.text = playerName;
            stage.focus = root["dialogue_login"].username;
            root["dialogue_login"].username.setSelection(0, root["dialogue_login"].username.text.length);
            root["dialogue_login"].visible = true;
        }

        //
        //
        public function showInstructions ():void {
            root["dialogue_instructions"].visible = true;
        }

        //
        //
        public function showWelcome ():void {

            if (lastPlayerName != null) {

                root["welcome_message"].text = "Welcome back, " + lastPlayerName + "!\n";

                if (!isNaN(lastScore)) {

                    root["welcome_message"].text += "Your last score was: " + lastScore;

                }

            }

        }

        //
        //
        public function getScoreData ():void {

            MochiScores.requestList(this, "onScoresReceived");

        }

        //
        //
        public function showScores ():void {

            // To show the "Speed Round" board, add options object
            // {boardID: "ba84e47f9be63b0a"}

            MochiScores.showLeaderboard( { res: "550x400", onClose: function ():void { }, onError: function ():void { trace("error loading leaderboard!"); } } );

        }

        //
        //
        public function onScoresReceived (args:Object):void {

            if (args.scores != null) {

                trace("Scores received!");

                var newScores:Object = MochiScores.scoresArrayToObjects(args.scores);

            } else {

                if (args.error) {
                    trace("Error: " + args.errorCode);
                }

            }

        }

        //
        //
        public function onPlayerInfoReceived (info:Object):void {

            trace("Player info received...");

            if (info.name != undefined) {
                if (info.name.length > 0) {
                    lastPlayerName = info.name;
                }
            }

            if (lastPlayerName != null) {
                playerName = lastPlayerName;
            }

            if (info.scores != undefined) {
                if (info.scores[boardID] != undefined) {
                    lastScore = info.scores[boardID];
                }
            }

            if (root["welcome_message"] != undefined) {
                showWelcome();
            }

        }

        //
        //
        public function startGame ():void {

            score.setValue( 0 );
            root["username"].text = playerName;

            _startTime = getTimer() + Math.floor(Math.random() * 10000); // add random game start time for variation

            _timer = new Timer(500);
            _timer.addEventListener(TimerEvent.TIMER, gameLoop);
            _timer.start();

        }

        //
        //
        public function gameLoop (e:TimerEvent):void {

            if (getTimer() - _startTime < 7000) {

                if (Math.random() * 2 >> 0 == 1) {
                    score.addValue( Math.random() * 20 >> 0 );
                }

                root["myscore"].text = score + "";

            } else {

                _timer.removeEventListener(TimerEvent.TIMER, gameLoop);
                endGame();

            }

        }

        //
        //
        public function endGame ():void {

            var _item:String;
            var itemNum:Number = int(Math.random()*50);

            while( itemNum-- > 0 )
                for (var key:String in _storeItems)
                    if( --itemNum < 0 )
                        _item = key;

            MochiCoins.showItem( {item:_item} );

            _gameTime = Math.floor(getTimer() - _startTime);
            gotoAndStop("game over");

        }

        //
        //
        public function showFinalScore ():void {

            root["myscore"].text = score + "";

            var gameTime:Number = Math.floor(_gameTime / 100) / 10;
            var gameTimeString:String = "";

            if (gameTime >= 60) {
                gameTimeString += Math.floor(gameTime / 60) + " min ";
            }

            gameTimeString += (gameTime % 60) + " sec";

            root["gametime"].text = gameTimeString;

        }


        //
        //
        public function submitScore ():void {

            var options = {
                score: score,
                onClose: showAd
            }

            // to Submit to the "Speed Round" board, uncomment the next two lines

            // options.boardID = "ba84e47f9be63b0a";
            // options.score = _gameTime;


            MochiScores.showLeaderboard(options);


        }


        private function showAd ():void {
            //Include MochiAd.as in this folder and uncomment the lines below to show an ad
            //trace("SHOWING AD");
            //MochiAd.showInterLevelAd({ id:"84993a1de4031cd8", res:"550x400", no_bg:false, ad_finished: mainMenu});
        }

    }

}

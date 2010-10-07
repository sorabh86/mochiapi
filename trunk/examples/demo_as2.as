import mochi.as2.*;

/**
 * Sample Game
 * This is a sample game that utilizes MochiServices
 * Be sure to place the mochi folder in the classpath of your game
 */

class demo_as2 {

    public static var gameID:String;

    public var playerName:String;

    public var boardID:String;
    public var score:Number;

    public var lastPlayerName:String;
    public var lastScore:Number;

    private var _startTime:Number;
    private var _gameTime:Number;
    private var loopInterval:Number;
    private var _storeItems:Object;

    //
    //
    public function demo_as2 () {

        init();

        MochiSocial.addEventListener(MochiSocial.ERROR, coinsError);
        MochiSocial.addEventListener(MochiSocial.LOGGED_IN, coinsEvent);
        MochiCoins.addEventListener(MochiCoins.ITEM_OWNED, coinsEvent);
        MochiCoins.addEventListener(MochiCoins.STORE_ITEMS, storeItems);
    }

    /**
     * Method: connectServices
     * Connects sample game to MochiServices
     * This is called in a frame of the root timeline before the game starts
     * @param   gameID
     */
    public static function connectServices (gameID:String):Void {
        demo_as2.gameID = gameID;
        MochiServices.connect(gameID);
    }

    private function coinsEvent(event:Object):Void {
        trace("[GAME] [coinsEvent] " + event);
    }

    private function coinsError(error:Object):Void {
        trace("[GAME] [coinsError] " + error.type);
    }

    private function storeItems(arg:Object):Void {
        _storeItems = arg;

        for (var key:String in arg )
            trace("[GAME] [StoreItems] " + arg[key].id );
    }

    /**
     * Method: init
     * Initializes the sample game
     * Notice that the boardID for this game is set here.
     */
    private function init ():Void {
        boardID = "a4b4d5eab22720b4";

        MochiCoins.getStoreItems();
        MochiScores.setBoardID(boardID);

        var del:MochiEventDispatcher = new MochiEventDispatcher();

        playerName = "";
        score = 0;

        mainMenu();

    }

    //
    //
    public function mainMenu ():Void {
        _root.gotoAndStop("game menu");

        MochiSocial.showLoginWidget({x:36+10, y:340-14});
        //submitScore();
    }

    //
    //
    public function playGame ():Void {
        MochiSocial.hideLoginWidget()
        _root.gotoAndStop("game play");
    }

    //
    //
    public function showLogin ():Void {
        _root["dialogue_login"].username.text = playerName;
        Selection.setFocus(_root["dialogue_login"].username);
        Selection.setSelection();
        _root["dialogue_login"]._visible = true;
    }

    //
    //
    public function showInstructions ():Void {
        _root["dialogue_instructions"]._visible = true;
    }

    //
    //
    public function showWelcome ():Void {

        trace("showing welcome message..");

        if (lastPlayerName != undefined) {

            _root["welcome_message"].text = "Welcome back, " + lastPlayerName + "!\n";

            if (lastScore != undefined) {

                _root["welcome_message"].text += "Your last score was: " + lastScore;

            }


        }

        //MochiAd.showPreGameAd( { id:"84993a1de4031cd8", ad_finished: null } );
        //MochiAd.fetchHighScores( {id:"84993a1de4031cd8"}, this, "gotHighScores");
        //getScoreData();

    }

    //
    //
    function gotHighScores (scores:Object):Void {
        trace("------- GOT HIGH SCORES -----");
    }

    //
    //
    public function getScoreData ():Void {

        trace("requesting scores");
        MochiScores.requestList(this, "onScoresReceived");

    }



    //
    //
    public function onScoresReceived (args:Object):Void {

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
    public function showScores ():Void {

        // To show the "Speed Round" board, add options object
        // {boardID: "ba84e47f9be63b0a"}

        //MochiScores.showLeaderboard( { onClose: function () { } } );
        //, clip: _root["myscores"]
        MochiScores.showLeaderboard( { res: "470x320", clip: _root.myscores, numScores: 8, preloaderDisplay: true, onClose: function () { trace("show closed: " + arguments[0]);  }, onError: function (errorCode:String):Void { trace("show error: " + errorCode); } } );
        //MochiScores.showLeaderboard( { res: "550x400", showbg: false, numScores: 55, showTableRank: true, preloaderDisplay: true, onClose: function () { trace("show closed: " + arguments[0]);  }, onError: function (errorCode:String):Void { trace("show error: " + errorCode); } } );

    }

    //
    //
    public function closeScores ():Void {

        MochiScores.closeLeaderboard();
        MochiScores.showLeaderboard( { boardID: "ba84e47f9be63b0a", width: 470, height: 320, showbg: false, numScores: 25, clip: _root.myscores, showTableRank: true, preloaderDisplay: true, onClose: function () { trace("show closed: " + arguments[0]);  }, onError: function (errorCode:String):Void { trace("show error: " + errorCode); } } );

    }

    //
    //
    public function getPlayerInfo ():Void {

        MochiScores.getPlayerInfo(this, "onPlayerInfoReceived");

    }

    //
    //
    public function onPlayerInfoReceived (info:Object):Void {

        trace("player info received...");

        if (info.name != undefined && info.name.length > 0) {
            lastPlayerName = info.name;
        }

        if (lastPlayerName != undefined) {
            playerName = lastPlayerName;
        }

        if (info.scores[boardID] != undefined) {
            lastScore = info.scores[boardID];
        }

        if (_root["welcome_message"] != undefined) {
            showWelcome();
        }

    }

    //
    //
    public function startGame ():Void {

        score = 0;
        _root["username"].text = playerName;

        _startTime = getTimer() + Math.floor(Math.random() * 2000); // add random game start time for variation

        loopInterval = setInterval(this, "gameLoop", 500);

    }

    //
    //
    public function gameLoop ():Void {

        if (getTimer() - _startTime < 2000) {

            if (Math.random() * 2 >> 0 == 1) {
                score += 100 + Math.floor(Math.random() * 1000);
            }

            _root["myscore"].text = score + "";

        } else {

            clearInterval(loopInterval);
            endGame();

        }

    }

    //
    //
    public function endGame ():Void {
        var _item:String;
        var itemNum:Number = int(Math.random()*50);

        _item = _storeItems[0].id;

        _gameTime = Math.floor(getTimer() - _startTime);
        _root.gotoAndStop("game over");

        MochiCoins.showItem( {x:150,y:150,item:_item} );
    }

    //
    //
    public function showFinalScore ():Void {

        _root["myscore"].text = score + "";

        var gameTime:Number = Math.floor(_gameTime / 100) / 10;
        var gameTimeString:String = "";

        if (gameTime >= 60) {
            gameTimeString += Math.floor(gameTime / 60) + " min ";
        }

        gameTimeString += (gameTime % 60) + " sec";

        _root["gametime"].text = gameTimeString;

    }


    //
    //
    public function submitScore ():Void {

        var options = {
            score: score,
            name: playerName,
            clip: _root,
            boardID:'a4b4d5eab22720b4',
            numScores: 12,
            showTableRank: true,
            onClose: function ():Void {
                _global.game.mainMenu();
            }
        }

        // to Submit to the "Speed Round" board, uncomment the next two lines

        //options.boardID = "ba84e47f9be63b0a";

        MochiScores.showLeaderboard(options);
//          MochiScores.submit( score, playerName, _global.game, _global.game.mainMenu );
    }


    /**
     * Method: main
     * Instantiates the game
     */
    public static function main ():Void {

        var mygame:demo_as2 = new demo_as2();
        _global.game = mygame;

    }

}

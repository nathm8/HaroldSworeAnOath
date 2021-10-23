import MessageManager;
import MessageManager.Message;
import MessageManager.MessageListener;
import MessageManager.EndTurnMessage;

final tweenManager = TweenManager.singleton;
final messageManager = MessageManager.singleton;
final uiManager = UIManager.singleton;

class Main extends hxd.App implements MessageListener {

	var gameScene: GameScene;

	static function main() {
		new Main();
	}

	override private function init() {
		// boilerplate
		hxd.Res.initEmbed();

		// controls
		hxd.Window.getInstance().addEventTarget(onEvent);
		
		// gamelogic
		mainMenu();
		// newGame();
	}
	
	override function update(dt:Float) {
		if (gameScene != null)
			gameScene.update(dt);
		tweenManager.update(dt);
	}
	
	function mainMenu() {
		this.setScene2D(new MainMenu(this.newGame));
	}

	function newGame() {
		tweenManager.reset();
		messageManager.reset();
		uiManager.reset();
		var gameState = new GameState();
		gameScene = new GameScene(gameState);
		gameScene.newGame();
		this.setScene2D(gameScene);
		messageManager.addListener(this);
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EKeyDown:
				switch (event.keyCode) {
					case hxd.Key.R:
						newGame();
					case hxd.Key.ENTER:
						if (gameScene.gameState.currentPlayer == gameScene.gameState.humanPlayer)
							messageManager.sendMessage(new EndTurnMessage());
				}
			case _:
		}
	}


	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, RestartMessage)) {
			newGame();
			return true;
		}
		if (Std.isOfType(msg, MainMenuMessage)) {
			mainMenu();
			return true;
		}
		return false;
	}
}
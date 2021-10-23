import Constants;

final tweenManager = TweenManager.singleton;
final messageManager = MessageManager.singleton;
final uiManager = UIManager.singleton;

class Main extends hxd.App {

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
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EKeyDown:
				switch (event.keyCode) {
					case hxd.Key.R:
						newGame();
					case _:
				}
			case _:
		}
	}

}
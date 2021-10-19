import h2d.Bitmap;

final tweenManager = TweenManager.singleton;

class Main extends hxd.App {

	var gameState: GameState;
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
		newGame();
	}
	
	override function update(dt:Float) {
		if (gameScene != null)
			gameScene.update(dt);
		tweenManager.update(dt);
	}
	
	function newGame() {
		gameScene = new GameScene();
		gameState = new GameState();
		gameScene.newGame(gameState);
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
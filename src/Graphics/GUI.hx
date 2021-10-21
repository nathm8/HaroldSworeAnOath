import MessageManager;
import h2d.Text;
import MessageManager.Message;
import MessageManager.MessageListener;
import Constants;
import h2d.Bitmap;

final messageManager = MessageManager.singleton;

class GUI implements MessageListener {

    var landText:Text;
    var rightText:Text;
    var gameScene: GameScene;

    public function new(gs: GameScene) {
        gameScene = gs;
		var backgroundButtonTile = hxd.Res.img.ButtonBG.toTile();
		backgroundButtonTile.setCenterRatio();
		var backgroundButton = new Bitmap(backgroundButtonTile, gameScene);
		backgroundButton.x = 500;
		backgroundButton.y = 750;
		backgroundButton.color = COLOURS[gameScene.gameState.currentTurn];
		var buttonText = new h2d.Text(hxd.res.DefaultFont.get(), backgroundButton);
		buttonText.y = -10;
		buttonText.text = "End Turn";
		buttonText.textAlign = Center;

		var rightTile = hxd.Res.img.Right.toTile();
		rightTile.setCenterRatio();
		var right = new Bitmap(rightTile, gameScene);
		right.x = 400;
		right.y = 750;
		right.color = COLOURS[gameScene.gameState.currentTurn];
		rightText = new h2d.Text(hxd.res.DefaultFont.get(), right);
		rightText.text = Std.string(gameScene.gameState.divineRight[gameScene.gameState.currentTurn]);
		rightText.textAlign = Center;
		rightText.x = 0.5;
		rightText.y = -9;

		var landTile = hxd.Res.img.Hex.toTile();
		landTile.setCenterRatio();
		var land = new Bitmap(landTile, gameScene);
		land.x = 600;
		land.y = 750;
		land.color = COLOURS[gameScene.gameState.currentTurn];
		landText = new h2d.Text(hxd.res.DefaultFont.get(), land);
		landText.text = Std.string(gameScene.gameState.land[gameScene.gameState.currentTurn]);
        landText.textAlign = Center;
        landText.x = 0.5;
		landText.y = -9;

		messageManager.addListener(this);
    }

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, UpdateEconomyGUIMessage)) {
			landText.text = Std.string(gameScene.gameState.land[gameScene.gameState.currentTurn]);
			rightText.text = Std.string(gameScene.gameState.divineRight[gameScene.gameState.currentTurn]);
            return true;
        }
        return false;
	}
}
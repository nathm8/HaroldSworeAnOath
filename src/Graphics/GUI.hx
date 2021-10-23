import h2d.col.Point;
import h2d.col.Polygon;
import h2d.col.Polygons;
import h2d.col.PolygonCollider;
import hxd.Event;
import MessageManager;
import h2d.Text;
import MessageManager.Message;
import MessageManager.MessageListener;
import Constants;
import h2d.Bitmap;

final messageManager = MessageManager.singleton;

class GUI implements MessageListener {

	var buttonText:Text;
    var landText:Text;
    var rightText:Text;
    var gameScene: GameScene;
	var backgroundButton: Bitmap;
	var right: Bitmap;
	var land: Bitmap;

    public function new(gs: GameScene) {
        gameScene = gs;
		var backgroundButtonTile = hxd.Res.img.ButtonBG.toTile();
		backgroundButtonTile.setCenterRatio();
		backgroundButton = new Bitmap(backgroundButtonTile, gameScene);
		backgroundButton.x = 500;
		backgroundButton.y = 750;
		backgroundButton.color = COLOURS[gameScene.gameState.currentPlayer];
		buttonText = new h2d.Text(hxd.res.DefaultFont.get(), backgroundButton);
		buttonText.y = -10;
		buttonText.text = "End Turn";
		buttonText.textAlign = Center;

		var polys:Polygons = new Polygons();
		polys.push(new Polygon([
			new Point(-60, -22.5),
			new Point(60, -22.5),
			new Point(60, 22.5),
			new Point(-60, 22.5)
		]));
		var interaction = new h2d.Interactive(0, 0, backgroundButton, new PolygonCollider(polys, true));
		interaction.onClick = function(event:Event) {
			if (gameScene.gameState.currentPlayer == gameScene.gameState.humanPlayer)
				messageManager.sendMessage(new EndTurnMessage());
		};

		var rightTile = hxd.Res.img.Right.toTile();
		rightTile.setCenterRatio();
		right = new Bitmap(rightTile, gameScene);
		right.x = 400;
		right.y = 750;
		right.color = COLOURS[gameScene.gameState.currentPlayer];
		rightText = new h2d.Text(hxd.res.DefaultFont.get(), right);
		rightText.text = Std.string(gameScene.gameState.divineRight[gameScene.gameState.currentPlayer]);
		rightText.textAlign = Center;
		// rightText.x = -0.5;
		rightText.y = -9;

		var landTile = hxd.Res.img.Hex.toTile();
		landTile.setCenterRatio();
		land = new Bitmap(landTile, gameScene);
		land.x = 600;
		land.y = 750;
		land.color = COLOURS[gameScene.gameState.currentPlayer];
		landText = new h2d.Text(hxd.res.DefaultFont.get(), land);
		landText.text = Std.string(gameScene.gameState.land[gameScene.gameState.currentPlayer]);
        landText.textAlign = Center;
        // landText.x = -0.5;
		landText.y = -9;

		messageManager.addListener(this);
    }

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, UpdateEconomyGUIMessage)) {
			backgroundButton.color = COLOURS[gameScene.gameState.currentPlayer];
			right.color = COLOURS[gameScene.gameState.currentPlayer];
			land.color = COLOURS[gameScene.gameState.currentPlayer];
			landText.text = Std.string(gameScene.gameState.land[gameScene.gameState.currentPlayer]);
			rightText.text = Std.string(gameScene.gameState.divineRight[gameScene.gameState.currentPlayer]);
			if (gameScene.gameState.currentPlayer == gameScene.gameState.humanPlayer)
				buttonText.text = "End Turn";
			else
				buttonText.text = "AI's Turn";
            return true;
        }
        return false;
	}
}
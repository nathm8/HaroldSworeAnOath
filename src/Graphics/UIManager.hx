import h2d.Bitmap;
import TweenManager.RaiseTween;
import Unit;
import MessageManager;

final messageManager = MessageManager.singleton;
final tweenManager = TweenManager.singleton;

class UIManager implements MessageListener {

	public static final singleton = new UIManager();
    public var gameScene(null, set): GameScene;
    var selectedUnit: UnitSprite;
    var selectedHex: Bitmap;

	private function new() {
        messageManager.addListener(this);
        selectedUnit = null;
	}

	public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, HexClickMessage)) {
            var hex = cast(msg, HexClickMessage).hex;
            if (selectedUnit == null) {
                for (us in gameScene.hexToUnitSprites[hex])
                    if (us.unit.type == UnitType.Knight) {
                        trace("selecting unit");
                        selectedUnit = us;
                        animateUnitSelection();
                        return true;
                    }
            }
            else {
                messageManager.sendMessage(new KnightMoveMessage(selectedUnit.unit.position, hex));
                animateUnitMovement(hex);
                selectedUnit = null;
                return true;
            }
        }
        if (Std.isOfType(msg, HexOverMessage)) {
			var hex = cast(msg, HexOverMessage).hex;
            trace(hex);
			var p = hex.toPixel();
            selectedHex.x = p.x;
            selectedHex.y = p.y;
        }
        return false;
	}

	function set_gameScene(value:GameScene):GameScene {
		gameScene = value;
		var hexTile = hxd.Res.img.HexSelect.toTile();
		hexTile.setCenterRatio();
		selectedHex = new Bitmap(hexTile);
        gameScene.add(selectedHex, 100);
		return gameScene;
	}

	function animateUnitSelection() {
        trace(selectedUnit.y);
		tweenManager.add(new RaiseTween(selectedUnit, selectedUnit.y, selectedUnit.y-6, 0, 0.5));
    }

	function animateUnitMovement(hex:Hex) {}
}
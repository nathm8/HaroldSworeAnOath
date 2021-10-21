import Constants;
import TweenManager;
import h2d.Bitmap;
import MessageManager;

final messageManager = MessageManager.singleton;
final tweenManager = TweenManager.singleton;

class UIManager implements MessageListener {

	public static final singleton = new UIManager();
    public var gameScene(null, set): GameScene;
    var selectedUnit: UnitSprite;
    var selectedUnitGhost: UnitSprite;
    var selectedHex: Bitmap;
    var movementHexes: Array<Bitmap>;

	private function new() {
        messageManager.addListener(this);
        selectedUnit = null;
	}

    public function reset() {
		messageManager.addListener(this);
		selectedUnit = null;
		selectedUnitGhost = null;
    }

	public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, HexClickMessage)) {
            var hex = cast(msg, HexClickMessage).hex;
            if (selectedUnit == null) {
				var unit = gameScene.gameState.hexToUnits[hex].knight;
                if (unit != null && unit.canMove) {
					selectedUnit = gameScene.unitToUnitSprites[unit];
                    animateUnitSelection();
                    setMovementHexesPosition(hex);
                    return true;
                }
            }
			else if (gameScene.gameState.canMove(selectedUnit.unit.position, hex)) {
				var is_attack = gameScene.gameState.canAttack(selectedUnit.unit.position, hex);
				animateUnitMovement(selectedUnit.unit.position, hex, is_attack);
                messageManager.sendMessage(new KnightMoveMessage(selectedUnit.unit.position, hex));
                selectedUnit = null;
                selectedUnitGhost.remove();
				selectedUnitGhost = null;
				hideMovementHexes();
                return true;
            }
        }
        if (Std.isOfType(msg, HexOverMessage)) {
			var hex = cast(msg, HexOverMessage).hex;
			var p = hex.toPixel();
            selectedHex.x = p.x;
            selectedHex.y = p.y;
			if (selectedUnit != null) {
                if (selectedUnit.unit.position.distance(hex) < 2) {
                    selectedUnitGhost.x = p.x;
                    selectedUnitGhost.y = p.y-6;
                }
            }
        }
        return false;
	}

	function set_gameScene(value:GameScene):GameScene {
		gameScene = value;
		var hexTile = hxd.Res.img.HexSelect.toTile();
		hexTile.setCenterRatio();
		var movementHexTile = hxd.Res.img.HexMove.toTile();
        movementHexTile.setCenterRatio();
		selectedHex = new Bitmap(hexTile);
        gameScene.add(selectedHex, 100);
		movementHexes = new Array<Bitmap>();
		tweenManager.add(new GlowInfiniteTween(selectedHex, 0 , 1));
        for (_ in 0...6) {
            var mh = new Bitmap(movementHexTile);
            gameScene.add(mh, 99);
			tweenManager.add(new GlowInfiniteTween(mh, 0 , 1));
            mh.visible = false;
            movementHexes.push(mh);
        }
		return gameScene;
	}

    function setMovementHexesPosition(h: Hex) {
        var neighbours = h.ring(1);
        for (i in 0...6) {
			if (!gameScene.gameState.canMove(h, neighbours[i]))
                continue;
            movementHexes[i].visible = true;
            var p = neighbours[i].toPixel();
			movementHexes[i].x = p.x;
			movementHexes[i].y = p.y;
        }
    }

    function hideMovementHexes() {
        for (mh in movementHexes)
			mh.visible = false;
    }

	function animateUnitSelection() {
		selectedUnitGhost = new UnitSprite(selectedUnit.unit, selectedUnit.parent);
		var col = selectedUnitGhost.color.clone();
		col.w = 0.5;
        selectedUnitGhost.color = col;
        selectedUnitGhost.y -= 6;

		tweenManager.add(new RaiseTween(selectedUnit, selectedUnit.y, selectedUnit.y - 6, 0, 0.5));
    }
    
	function animateUnitMovement(from:Hex, to:Hex, is_attack: Bool) {
        var orig = from.toPixel();
        var targ = to.toPixel();
		tweenManager.add(new MoveBounceTween(selectedUnit, orig, targ, 0, .75));
        tweenManager.add(new RaiseTween(selectedUnit, targ.y, targ.y + 3, -0.9, 0.5));
		tweenManager.add(new ColourTween(selectedUnit, COLOURS[selectedUnit.unit.owner], COLOURS_GREYED[selectedUnit.unit.owner], -0.9, 0.5));
        if (!is_attack) return;
        var back = to.add(to.subtract(from));
		tweenManager.add(new MoveBounceTween(gameScene.unitToUnitSprites[gameScene.gameState.hexToUnits[to].knight], to.toPixel(), back.toPixel(), 0, .75, true));
    }
}
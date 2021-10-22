import Constants;
import TweenManager;
import h2d.Bitmap;
import MessageManager;

final messageManager = MessageManager.singleton;
final tweenManager = TweenManager.singleton;

class UIManager implements MessageListener {

	public static final singleton = new UIManager();
    var gameScene: GameScene;
    var selectedUnit: UnitSprite;
    var selectedUnitGhost: UnitSprite;
    var selectedHex: Bitmap;
    var movementHexes: Array<Bitmap>;
    var gameState(get, never): GameState;
    var currentPlayer(get, never): Int;
    
    // top row UI
    var gui: GUI;

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
            // can't do anything if not our turn
            if (currentPlayer != gameState.humanPlayer) return true;
            var hex = cast(msg, HexClickMessage).hex;
            if (selectedUnit == null) {
				var unit = gameState.hexToUnits[hex].knight;
                if (unit != null && unit.canMove && unit.owner == currentPlayer) {
                    selectedUnit = gameScene.unitToUnitSprites[unit];
                    animateUnitSelection();
                    setMovementHexesPosition(hex);
                    return true;
                }
                unit = gameState.hexToUnits[hex].town;
				if (unit != null && unit.owner != currentPlayer && gameState.canBuy(currentPlayer, unit.owner) && currentPlayer == gameState.humanPlayer) {
					messageManager.sendMessage(new BuyTownMessage(hex, currentPlayer));
					return true;
				}
            }
			else if (gameState.canMove(selectedUnit.unit.position, hex)) {
				var is_attack = gameState.canAttack(selectedUnit.unit.position, hex);
				animateUnitMovement(selectedUnit.unit.position, hex, is_attack, selectedUnit.unit.position == hex);
				if (selectedUnit.unit.position != hex)
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
            } else {
                var unit = gameState.hexToUnits[hex].town;
				if (unit != null && unit.owner != currentPlayer && currentPlayer == gameState.humanPlayer) {
                    new CostIndicator(hex, gameScene, unit.owner, gameState.canBuy(currentPlayer, unit.owner));
                }
            }
            return true;
        }
		if (Std.isOfType(msg, AIMoveMessage)) {
			var fromHex = cast(msg, AIMoveMessage).fromHex;
			var toHex = cast(msg, AIMoveMessage).toHex;
			var is_attack = gameState.canAttack(fromHex, toHex);
			animateUnitMovement(fromHex, toHex, is_attack);
			messageManager.sendMessage(new KnightMoveMessage(fromHex, toHex));
            return true;
        }
        return false;
	}


	public function initialiseWithGameScene(value:GameScene):GameScene {
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
        gui = new GUI(gameScene);

		return gameScene;
	}

    function setMovementHexesPosition(h: Hex) {
        var neighbours = h.ring(1);
        for (i in 0...6) {
			if (!gameState.canMove(h, neighbours[i]))
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
    
	function animateUnitMovement(from:Hex, to:Hex, is_attack: Bool, is_cancel=false) {
        var orig = from.toPixel();
        var targ = to.toPixel();
        var unitsprite_to_move = gameScene.unitToUnitSprites[gameState.hexToUnits[from].knight];
		tweenManager.add(new MoveBounceTween(unitsprite_to_move, orig, targ, 0, .75));
        if (is_cancel) return;
        tweenManager.add(new RaiseTween(unitsprite_to_move, targ.y, targ.y + 3, -0.9, 0.5));
		tweenManager.add(new ColourTween(unitsprite_to_move, COLOURS[unitsprite_to_move.unit.owner], COLOURS_GREYED[unitsprite_to_move.unit.owner], -0.9, 0.5));
        if (!is_attack) return;
        var back = to.add(to.subtract(from));
		tweenManager.add(new MoveBounceTween(gameScene.unitToUnitSprites[gameState.hexToUnits[to].knight], to.toPixel(), back.toPixel(), 0, .75, true));
    }

	function get_gameState():GameState {
		return gameScene.gameState;
	}
    
	function get_currentPlayer():Int {
		return gameState.currentPlayer;
	}
}
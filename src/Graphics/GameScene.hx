import GUI.names;
import UIManager.messageManager;
import MessageManager;
import haxe.ds.HashMap;
import TweenManager;
import hxd.Rand;
import hxd.Key;
import h2d.Scene;

final tweenManager = TweenManager.singleton;
final uiManager = UIManager.singleton;

class GameScene extends Scene implements MessageListener {

	public var gameState: GameState;
	var hexToHexSprites: HashMap<Hex, HexSprite>;
	public var unitToUnitSprites:Map<Unit, UnitSprite>;
	
	public function new(gs:GameState) {
		super();
		gameState = gs;
		hexToHexSprites = new HashMap<Hex, HexSprite>();
		unitToUnitSprites = new Map<Unit, UnitSprite>();
		uiManager.initialiseWithGameScene(this);
		messageManager.addListener(this);
    }
	
	// animate a new game by laying down the hexes in a pattern
    public function newGame() {
		camera.setPosition(250, 250);
		camera.setScale(2, 2);
		
		var i = 0.0;
		var r = Rand.create();
		var gen_anim = r.rand();
		if (gen_anim < 0.4)
			gameState.world.sortHexesSpirally();
		else {
			var gen_anim2 = r.rand();
			if (gen_anim2 < 0.166)
				gameState.world.sortHexesByDirection({q:true});
			else if (gen_anim2 < 0.333)
				gameState.world.sortHexesByDirection({q: true, reversed: true});
			else if (gen_anim2 < 0.5)
				gameState.world.sortHexesByDirection({r:true});
			else if (gen_anim2 < 0.666)
				gameState.world.sortHexesByDirection({r: true, reversed: true});
			else if (gen_anim2 < 0.833)
				gameState.world.sortHexesByDirection({s:true});
			else
				gameState.world.sortHexesByDirection({s:true, reversed:true});
		}
		for (h in gameState.world.hexes) {
			var hs = new HexSprite(h);
			add(hs, 0);
			hexToHexSprites[h] = hs;
			tweenManager.add(new ScaleBounceTween(hs, -i/gameState.hexes.length, 0.5));
			i += 1;
		}
		tweenManager.add(new DelayedCallTween(drawTowns, -i/gameState.hexes.length-0.5, 0));
		tweenManager.add(new DelayedCallTween(colourTerritoriesFirstTurn, -i/gameState.hexes.length-0.5, 0));
		ysort(0);
    }
	
	public function drawTowns() {
		for (unit in gameState.units) {
			var s = new UnitSprite(unit);
			add(s, s.getLayer());
			unitToUnitSprites[unit] = s;
			tweenManager.add(new ScaleLinearTween(s, 0, 0.5));
		}
	}

	public function colourTerritoriesFirstTurn() {
		colourTerritories(true);
	}

	public function colourTerritories(firstTurn=false) {
		var territories = gameState.determineTerritories();
		for (h in gameState.hexes)
			hexToHexSprites[h].capturedBy(territories[h].owner, territories[h].dist);
		gameState.updateIncome();
		if (firstTurn) {
			gameState.getIncome(gameState.currentPlayer);
			messageManager.sendMessage(new UpdateEconomyGUIMessage());
		}
	}

	// control our camera
	public function update(dt:Float) {
		if (Key.isDown(Key.UP))
			camera.move(0, -100*dt);
		if (Key.isDown(Key.DOWN))
			camera.move(0, 100*dt);
		if (Key.isDown(Key.LEFT))
			camera.move(-100*dt, 0);
		if (Key.isDown(Key.RIGHT))
			camera.move(100*dt, 0);
		if (Key.isDown(Key.Q))
			camera.scale(1.1, 1.1);
		if (Key.isDown(Key.E))
			camera.scale(0.9, 0.9);
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, RecalculateTerritoriesMessage)) {
			colourTerritories();
			messageManager.sendMessage(new UpdateEconomyGUIMessage());
			return true;
		}
		return false;
	}
}

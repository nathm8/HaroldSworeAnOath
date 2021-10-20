import haxe.ds.HashMap;
import TweenManager;
import hxd.Rand;
import hxd.Key;
import h2d.Scene;

final tweenManager = TweenManager.singleton;

class GameScene extends Scene{

	var gameState: GameState;
	var sprites: Array<UnitSprite>;
	var hexToSprites: HashMap<Hex, HexSprite>;
	
    public function new() {
		super();
		sprites = new Array<UnitSprite>();
		hexToSprites = new HashMap<Hex, HexSprite>();
    }
	
	// animate a new game by laying down the hexes in a pattern
    public function newGame(gs: GameState) {
		gameState = gs;
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
			var hs = new HexSprite(h, this);
			hexToSprites[h] = hs;
			hs.visible = false;
			tweenManager.add(new ScaleBounceTween(hs, -i/gameState.hexes.length, 0.5));
			i += 1;
		}
		tweenManager.add(new DelayedCallTween(drawTowns, -i/gameState.hexes.length-0.5, 0));
		tweenManager.add(new DelayedCallTween(colourTerritories, -i/gameState.hexes.length-0.5, 0));
		ysort(0);
    }
	
	public function drawTowns() {
		for (unit in gameState.units) {
			var s = new UnitSprite(unit, this);
			sprites.push(s);
			tweenManager.add(new ScaleLinearTween(s, 0, 0.5));
		}
	}

	public function colourTerritories() {
		var territories = gameState.world.determineTerritories(gameState.units);
		for (h in gameState.hexes) {
			if (territories[h].owner == gameState.hexOwners[h])
				continue;
			hexToSprites[h].capturedBy(territories[h].owner, territories[h].dist);
		}
	}

	// control our camera
	public function update(dt:Float) {
		if (Key.isDown(Key.UP))
			camera.move(0, -1000*dt);
		if (Key.isDown(Key.DOWN))
			camera.move(0, 1000*dt);
		if (Key.isDown(Key.LEFT))
			camera.move(-1000*dt, 0);
		if (Key.isDown(Key.RIGHT))
			camera.move(1000*dt, 0);
		if (Key.isDown(Key.Q))
			camera.scale(1.1, 1.1);
		if (Key.isDown(Key.E))
			camera.scale(0.9, 0.9);
		for (sprite in sprites)
			sprite.update(dt);
	}
}

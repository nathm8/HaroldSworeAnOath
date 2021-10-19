import hxd.Rand;
import h2d.Bitmap;
import h2d.Layers;
import hxd.Key;
import h2d.Camera;
import h2d.Scene;

final tweenManager = TweenManager.singleton;

class GameScene extends Scene{

	var gameState: GameState;

    public function new() {
        super();
    }
	
    public function newGame(gs: GameState) {
		gameState = gs;
		camera.setPosition(0, 0);
		camera.setScale(1, 1);
		
		var i = 0.0;
		var r = Rand.create();
		var gen_anim = r.rand();
		if (gen_anim < 0.33)
			gameState.world.sortHexesSpirally();
		else if (gen_anim < 0.66) {
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
		else
			gameState.world.sortHexesRandomly();
		for (h in gameState.world.hexes) {
			var hs = new HexSprite(h, this);
			hs.visible = false;
			tweenManager.add(new ScaleBounceTween(hs, -i/gameState.hexes.length, 0.5));
			i += 1;
		}
		ysort(0);
    }

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
	}
}
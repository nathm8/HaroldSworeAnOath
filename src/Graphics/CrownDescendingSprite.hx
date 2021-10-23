import h2d.Tile;
import Constants.COLOURS;
import TweenManager;
import GameScene.tweenManager;
import h2d.Bitmap;

class CrownDescendingSprite extends Bitmap {
    
	static var crownTile:Tile;
	static var initialised = false;

    public function new(h: Hex, p: Int, gs: GameScene) {
		if (!initialised)
			init();
		super(crownTile);
        gs.add(this, 101);
        color = COLOURS[p];
        x = h.toPixel().x;
		tweenManager.add(new RaiseSmoothTween(this, h.toPixel().y - 20, h.toPixel().y - 5, 0, 1));
		tweenManager.add(new FadeOutTween(this, 0, 1.5));
    }

	function init() {
		initialised = true;
		crownTile = hxd.Res.img.Right.toTile();
		crownTile.setCenterRatio();
	}
}
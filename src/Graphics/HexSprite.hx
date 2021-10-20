import Constants;
import TweenManager;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

final tweenManager = TweenManager.singleton;

class HexSprite extends Bitmap {
    
    static var hexTile: Tile;
	static var initialised = false;
    var owner = -1;
    var hex: Hex;

    public function new(hex: Hex, ?parent:Object) {
        if (!initialised)
            init();
		super(hexTile, parent);
        this.hex = hex;
        x = hex.toPixel().x;
        y = hex.toPixel().y;
    }

    function init() {
        initialised = true;
		hexTile = hxd.Res.img.Hex.toTile();
        hexTile.setCenterRatio();
    }

	public function capturedBy(new_owner_id: Int, d:Int) {
		var col = new_owner_id == -1 ? COLOURS[7] : COLOURS[new_owner_id];
        // color = col;
		tweenManager.add(new ColourTween(this, color, col, -d*0.1, 0.5));
        owner = new_owner_id;
    }
}
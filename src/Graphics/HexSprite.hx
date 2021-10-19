import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

var hexTile: Tile;

class HexSprite extends Bitmap {

	static var initialised = false;

    public function new(hex: Hex, ?parent:Object) {
        if (!initialised)
            init();
		super(hexTile, parent);
        x = hex.toPixel().x;
        y = hex.toPixel().y;
    }

    function init() {
        initialised = true;
		hexTile = hxd.Res.img.Hex.toTile();
        hexTile.setCenterRatio();
    }

}
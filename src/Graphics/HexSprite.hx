import h2d.col.Polygons;
import h2d.col.Polygon;
import MessageManager;
import hxd.Event;
import h2d.Interactive;
import h2d.col.PolygonCollider;
import Constants;
import TweenManager;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

final tweenManager = TweenManager.singleton;
final messageManager = MessageManager.singleton;

class HexSprite extends Bitmap {
    
    static var hexTile: Tile;
	static var initialised = false;
	// static var pixels: Pixels;
    var owner = -1;
    var hex: Hex;
    var interaction: Interactive;

    public function new(hex: Hex, ?parent:Object) {
        if (!initialised)
            init();
		super(hexTile, parent);
        this.hex = hex;
        x = hex.toPixel().x;
        y = hex.toPixel().y;
        initInteraction();
    }

    function init() {
        initialised = true;
		hexTile = hxd.Res.img.Hex.toTile();
        hexTile.setCenterRatio();
        // pixels = hexTile.getTexture().capturePixels();
    }

	public function capturedBy(new_owner_id: Int, d:Int) {
		var col = new_owner_id == -1 ? COLOURS[7] : COLOURS[new_owner_id];
        // color = col;
		tweenManager.add(new ColourTween(this, color, col, -d*0.1, 0.5));
        owner = new_owner_id;
    }

    // public function initInteraction() {
    //     interaction = new h2d.Interactive(0, 0, this, new PixelsCollider(pixels));
    //     interaction.onClick = function(event: Event) {
	// 		messageManager.sendMessage(new HexClickMessage(hex));
    //     };
    // }

        public function initInteraction() {
		var polys: Polygons = new Polygons();
		polys.push(new Polygon(hex.polygonCorners()));
		interaction = new h2d.Interactive(0, 0, this, new PolygonCollider(polys, true));
        interaction.onClick = function(event: Event) {
			messageManager.sendMessage(new HexClickMessage(hex));
        };
		interaction.onOver = function(event:Event) {
			messageManager.sendMessage(new HexOverMessage(hex));
		};
    }
}
import Constants.COLOURS;
import Unit.UnitType;
import h2d.Tile;
import h2d.Object;
import h2d.Bitmap;

class UnitSprite extends Bitmap {
    
    public var unit: Unit;
    static var init = false;
    static var unitTypeToTiles = new Map<UnitType, Tile>();

    public function new(u: Unit, ?parent: Object) {
        if (!init)
            initialise();
        unit = u;
		super(unitTypeToTiles[unit.type], parent);
        color = COLOURS[unit.owner];
        x = unit.position.toPixel().x;
        y = unit.position.toPixel().y;
    }

    function initialise() {
        init = true;
		unitTypeToTiles =  [
            UnitType.Knight => hxd.Res.img.Knight.toTile(),
            UnitType.Town => hxd.Res.img.Town.toTile(),
        ];
		for (_ => tile in unitTypeToTiles){
            tile.setCenterRatio();
        }
    }
}
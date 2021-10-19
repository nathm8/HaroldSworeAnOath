import h2d.Tile;
import h2d.Object;
import h2d.Bitmap;
import Unit.UnitType;

final exclude_death_pixel = [
	UnitType.Sword => [15, 16, 17],
	UnitType.Musket => [16],
	UnitType.Pike => [10, 16, 22],
	UnitType.Cavalry => [9, 15, 17]
];

var unitTypeToTiles = new Map<UnitType, Tile>();

class UnitSprite extends Bitmap {
    
    var unit: Unit;
    static var init = false;

    public function new(u: Unit, ?parent: Object) {
        if (!init)
            initialise();
        unit = u;
		super(unitTypeToTiles[unit.type], parent);
    }

    function initialise() {
        init = true;
		unitTypeToTiles =  [
            UnitType.Sword => hxd.Res.img.Sword.toTile(),
            UnitType.Musket => hxd.Res.img.Musket.toTile(),
            UnitType.Pike => hxd.Res.img.Pike.toTile(),
            UnitType.Cavalry => hxd.Res.img.Cavalry.toTile(),
            UnitType.Capitol => hxd.Res.img.Capitol.toTile()
        ];
		for (_ => tile in unitTypeToTiles)
            tile.setCenterRatio();
    }
}
import h2d.Scene;
import UIManager.messageManager;
import Constants;
import TweenManager;
import MessageManager;
import Constants.COLOURS;
import Unit.UnitType;
import h2d.Tile;
import h2d.Object;
import h2d.Bitmap;

final messageManager = MessageManager.singleton;
final tweenManager = TweenManager.singleton;

class UnitSprite extends Bitmap implements MessageListener{
    
    public var unit: Unit;
    static var init = false;
    static var unitTypeToTiles = new Map<UnitType, Tile>();

    public function new(u: Unit) {
        if (!init)
            initialise();
        unit = u;
		super(unitTypeToTiles[unit.type]);
        color = COLOURS[unit.owner];
        x = unit.position.toPixel().x;
        y = unit.position.toPixel().y;

        messageManager.addListener(this);
    }

    public function getLayer(): Int {
		if (unit.type == Knight) return 1;
        return 0;
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

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, StandUpMessage)) {
            if (cast(msg, StandUpMessage).unit == unit) {
				tweenManager.add(new RaiseTween(this, y, unit.position.toPixel().y, 0, 0.5));
				tweenManager.add(new ColourTween(this, COLOURS_GREYED[unit.owner], COLOURS[unit.owner], 0, 0.5));
                return true;
            }
        }
		if (Std.isOfType(msg, UpdateKnightColourMessage)) {
			if (cast(msg, UpdateKnightColourMessage).unit == unit) {
				// trace("UpdateKnightColourMessage");
				tweenManager.add(new RaiseTween(this, y, unit.position.toPixel().y + 3, 0, 0.5));
				tweenManager.add(new ColourTween(this, color, COLOURS_GREYED[unit.owner], 0, 0.5));
				return true;
			}
        }
        return false;
	}
}
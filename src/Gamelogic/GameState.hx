import UnitTypes.UnitType;

class GameState {

    public var world: World;
    public var hexes(get, never): Array<Hex>;
    public var units: Array<Unit>;

    public function new() {
        world = new World(50, 2);
        world.generateWorld();
        units = new Array<Unit>();
        var owner_id = 0;
        for (h in world.placeCapitols()) {
            units.push(new Unit(UnitType.Capitol, owner_id, h));
            owner_id += 1;
            trace(h);
        }
    }

    function get_hexes():Array<Hex> {
        return world.hexes;
    }
}
import haxe.ds.HashMap;
import Unit.UnitType;

class GameState {

    public var world: World;
    public var hexes(get, never): Array<Hex>;
    public var pathfinder(get, never): Astar;
    public var units: Array<Unit>;

    // cache
	public var hexOwners:HashMap<Hex, Int>;

    public function new() {
        world = new World(100);
        world.generateWorld();
        hexOwners = new HashMap<Hex, Int>();
        for (h in world.hexes)
			hexOwners[h] = -1;
        units = new Array<Unit>();
        var owner_id = 0;
        for (h in world.placeTowns()) {
            units.push(new Unit(UnitType.Knight, owner_id, owner_id, h));
            units.push(new Unit(UnitType.Town, owner_id, owner_id, h));
            owner_id = (owner_id+1)%7;
        }
    }

    function get_hexes():Array<Hex> {
        return world.hexes;
    }

	function get_pathfinder():Astar {
		return world.pathfinder;
	}
}
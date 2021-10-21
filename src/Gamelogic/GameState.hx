import World;
import MessageManager;
import haxe.ds.HashMap;
import Unit.UnitType;
import hxd.Rand;

final messageManager = MessageManager.singleton;

class GameState implements MessageListener {

    public var world: World;
    public var hexSet(get, null): Set<Hex>;
    public var hexes(get, never): Array<Hex>;
    public var pathfinder(get, never): Astar;
    public var units: Array<Unit>;
    public var hexToUnits: HashMap<Hex, {town:Unit, knight:Unit}>;
    public var currentTurn: Int;
	public var divineRight: Map<Int, Int>;
    public var land: Map<Int, Int>;
	var territories:HashMap<Hex, OwnerDist>;

    public function new() {
        world = new World(50);
        world.generateWorld();
		hexToUnits = new HashMap<Hex, {town:Unit, knight:Unit}>();
        for (h in world.hexes) {
			hexToUnits[h] = {town: null, knight:null};
        }
        units = new Array<Unit>();
		var r = Rand.create();
		var owner_id = r.random(7);
        for (h in world.placeTowns()) {
			var town = new Unit(UnitType.Town, owner_id, h);
			var knight = new Unit(UnitType.Knight, owner_id, h, town);
            units.push(town);
            units.push(knight);
			hexToUnits[h].knight = knight;
			hexToUnits[h].town = town;
			owner_id = r.random(7);
        }
		currentTurn = Std.random(7);
		divineRight = [0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0];
		land = [0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0];
		messageManager.addListener(this);
    }

    function get_hexes():Array<Hex> {
        return world.hexes;
    }

	function get_pathfinder():Astar {
		return world.pathfinder;
	}

    public function canMove(from: Hex, to: Hex):Bool {
        var from_knight = hexToUnits[from].knight;
        var to_knight = hexToUnits[to].knight;
        // have to be something to move
		if (from_knight == null)
            return false;
        // can't move if not our turn
        if (from_knight.owner != currentTurn)
            return false;
        // have to be somewhere to move
        if (!hexSet.exists(to))
            return false;
        // have not yet this turn
        if (!from_knight.canMove)
            return false;
		if (to_knight != null && !canAttack(from, to))
            return false;
        return true;
    }

	public function canAttack(from:Hex, to:Hex):Bool {
		var from_knight = hexToUnits[from].knight;
		var to_knight = hexToUnits[to].knight;
        var to_town = hexToUnits[to].town;
        // can't attack without two knights
		if (from_knight == null || to_knight == null)
            return false;
		// can't attack if not our turn
		if (from_knight.owner != currentTurn)
            return false;
		// can't attack our own knights
		if (from_knight.owner == to_knight.owner)
			return false;
		// can't attack knights in castles
		if (to_town != null)
			return false;
        // can't knock back knight if there's no space behind them
		var back = to.add(to.subtract(from));
        if (!hexSet.exists(back) || hexToUnits[back].knight != null)
            return false;
        return true;
    }
    
	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, KnightMoveMessage)) {
			var from = cast(msg, KnightMoveMessage).fromHex;
			var to = cast(msg, KnightMoveMessage).toHex;
            if (canAttack(from, to)) {
                var unit = hexToUnits[to].knight;
				unit.position = to.add(to.subtract(from));
				hexToUnits[unit.position].knight = unit;
            }
            var unit = hexToUnits[from].knight;
            unit.position = to;
            unit.canMove = false;
            hexToUnits[unit.position].knight = unit;
            hexToUnits[from].knight = null;
			messageManager.sendMessage(new RecalculateTerritoriesMessage());
            return true;
        }
        return false;
	}

	function get_hexSet():Set<Hex> {
		return world.hexSet;
	}

	public function determineTerritories() : HashMap<Hex, OwnerDist> {
		territories = world.determineTerritories(units);
        return territories;
	}
    
    public function getIncome(player:Int, firstTurn=false) {
        for (p => l in land) {
            if (firstTurn)
                divineRight[p] += l;
            else if (p == player)
                divineRight[p] += l;
        }
    }

    public function updateIncome() {
		land = [0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0];
        for (_ => od in territories)
            land[od.owner]++;
    }

}
import UnitSprite.messageManager;
import TweenManager.DelayedCallTween;
import GameScene.tweenManager;
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
    public var currentPlayer: Int;
	public var divineRight: Map<Int, Int>;
    public var land: Map<Int, Int>;
    public var eliminated: Map<Int, Bool>;
	var territories:HashMap<Hex, OwnerDist>;
    public var humanPlayer: Int;

    public function new() {
        world = new World(50);
        world.generateWorld();
		hexToUnits = new HashMap<Hex, {town:Unit, knight:Unit}>();
        for (h in world.hexes) {
			hexToUnits[h] = {town: null, knight:null};
        }
        units = new Array<Unit>();
		var r = Rand.create();
		eliminated = [
			0 => true,
            1 => true,
            2 => true,
            3 => true,
            4 => true,
            5 => true,
            6 => true];
		var owner_id = r.random(7);
        for (h in world.placeTowns()) {
            eliminated[owner_id] = false;
			var town = new Unit(UnitType.Town, owner_id, h);
			var knight = new Unit(UnitType.Knight, owner_id, h, town);
            units.push(town);
            units.push(knight);
			hexToUnits[h].knight = knight;
			hexToUnits[h].town = town;
			owner_id = r.random(7);
        }
		currentPlayer = Std.random(7);
        while (eliminated[currentPlayer])
            currentPlayer = Std.random(7);
		humanPlayer = currentPlayer;
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
        // has to be somewhere to move to\from
		if (!(hexSet.exists(to) && hexSet.exists(from)))
            return false;
        var from_knight = hexToUnits[from].knight;
        var to_knight = hexToUnits[to].knight;
        // have to be something to move
		if (from_knight == null)
            return false;
        // can't move if not our turn
        if (from_knight.owner != currentPlayer)
            return false;
        // have not yet moved this turn
        if (!from_knight.canMove)
            return false;
        // can only move to neighbouring hexes, or back to start
        var in_range = from.equals(to);
        for (h in to.ring(1))
            in_range = in_range || from.equals(h);
        if (!in_range)
            return false;
        // can attack if destination is occupied
		if (to_knight != null && !canAttack(from, to))
            return false;
        return true;
    }

	public function canAttack(from:Hex, to:Hex):Bool {
		// has to be somewhere to attack to\from
		if (!(hexSet.exists(to) && hexSet.exists(from)))
			return false;
		var from_knight = hexToUnits[from].knight;
		var to_knight = hexToUnits[to].knight;
        var to_town = hexToUnits[to].town;
        // can't attack without two knights
		if (from_knight == null || to_knight == null)
            return false;
		// can't attack if not our turn
		if (from_knight.owner != currentPlayer)
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
			if (hexToUnits[to].town != null && hexToUnits[to].town.owner != unit.owner)
                conquerTown(to, unit.owner);
            else // just to prevent Recalc being called twice, as double tweens can look glitchy
			    messageManager.sendMessage(new RecalculateTerritoriesMessage());
            return true;
        }
		if (Std.isOfType(msg, EndTurnMessage)) {
            endTurn();
            return true;
        }
		if (Std.isOfType(msg, BuyTownMessage)) {
			var hex = cast(msg, BuyTownMessage).hex;
			var player = cast(msg, BuyTownMessage).player;
            buyTown(hex, player);
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

	function endTurn() {
        getIncome(currentPlayer);
		for (u in units) {
			if (u.owner != currentPlayer) continue;
            if (u.type == Knight && !u.canMove) {
                u.canMove = true;
				messageManager.sendMessage(new StandUpMessage(u));
            }
        }
        currentPlayer = (currentPlayer+1)%7;
		while (eliminated[currentPlayer])
            currentPlayer = (currentPlayer+1)%7;
		messageManager.sendMessage(new UpdateEconomyGUIMessage());
        if (currentPlayer == humanPlayer) return;
        // AI
        aiTurn();
    }

	function aiTurn() {
        var moves = new Array<Message>();
        trace("ai turn", currentPlayer);
        for (u in units) {
            if (u.owner != currentPlayer) continue;
            if (u.type != Knight) continue;
			var moves_priorities = new PriorityQueue<Hex>();
            for (n in u.position.ring(1)) {
                // attacking enemies a priority
                if (canAttack(u.position, n))
                    moves_priorities.push(n, 1);
                // defending our town high priority
				if (hexToUnits[n].town != null && hexToUnits[n].town.owner == currentPlayer) {
                    for (tn in n.ring(1))
						if (hexToUnits[tn].knight != null && hexToUnits[tn].knight.owner != currentPlayer){
                            moves_priorities.push(n, 10);
                            break;
                        }
                }
                // capturing towns highest priority
				if (canMove(u.position, n) && hexToUnits[n].knight == null && hexToUnits[n].town != null && hexToUnits[n].town.owner != currentPlayer)
                    moves_priorities.push(n, 100);
            }
            // if we have a priority move take it
            if (moves_priorities.size() > 0) {
				var m = moves_priorities.pop();
				trace("taking priority move", m);
				moves.push(new AIMoveMessage(u.position, m));
            }
            // otherwise move towards nearest enemy unit
            else {
                var min_d = 100;
                var n = new Hex(0,0,0);
				for (e in units) {
                    if (e.owner == currentPlayer)
						continue;
                    var path = pathfinder.findPath(u.position, e.position);
                    if (path.length < min_d && canMove(u.position, path[path.length-2])) {
						min_d = path.length;
						n = path[path.length-2];
                    }
                }
				var m = new AIMoveMessage(u.position, n);
                trace("moving towards nearest", m);
                moves.push(m);
            }
        }
        // create priority queue of (town, cost)
        // go through all buy all the towns we can, most expensive first
        // then do another round of troop movement
		trace("ai turn buying", currentPlayer);
        var player_land = new Array<{land:Int, player:Int}>();
        for (p => l in land) player_land.push({land:l, player:p});
        player_land.sort((a,b) -> a.land-b.land );
        var dr = divineRight[currentPlayer];

        var biggest = new PriorityQueue<{h:Hex, c:Int}>();
        for (u in units) {
            if (u.type == Town && u.owner != currentPlayer && land[u.owner] < dr)
				biggest.push({h: u.position, c: land[u.owner]}, land[u.owner]);
        }
        while (biggest.size() > 0) {
            var town = biggest.pop();
            if (town.c > dr) break;
			dr -= town.c;
            // the towns' costs will actually go down as we progress here, so AI won't buy as aggressively as it could
            moves.push(new BuyTownMessage(town.h, currentPlayer));
        }
        trace("ai turn buying done", currentPlayer);

		moves.push(new EndTurnMessage());
        var delay = 0.0;
        for (m in moves) {
            trace("queuing move", m);
			tweenManager.add(new DelayedCallTween(() -> messageManager.sendMessage(m), -delay, 0));
            delay += 1.5;
        }
        trace("ai turn done");
    }

	public function canBuy(buyer:Int, buyee:Int) : Bool {
		return divineRight[buyer] >= land[buyee];
	}

	function buyTown(hex:Hex, buyer:Int) {
        var town = hexToUnits[hex].town;
        var cost = land[town.owner];
        divineRight[buyer] -= cost;
        conquerTown(hex, buyer);
    }
    
	function conquerTown(hex:Hex, buyer:Int) {
		var town = hexToUnits[hex].town;
		var previous_owner = town.owner;
		town.owner = buyer;
		for (u in units)
			if (u.home == town) {
                u.owner = buyer;
                u.canMove = false;
				messageManager.sendMessage(new UpdateKnightColourMessage(u));
				break;
			}
        // check if this player has any units left
        var player_eliminated = true;
        for (u in units)
            if (u.owner == previous_owner) {
                player_eliminated = false;
                break;
            }
        eliminated[previous_owner] = player_eliminated;

        updateIncome();
        messageManager.sendMessage(new RecalculateTerritoriesMessage());
    }
}
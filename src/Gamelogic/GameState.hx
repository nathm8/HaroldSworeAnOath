import UnitSprite.messageManager;
import TweenManager.DelayedCallTween;
import GameScene.tweenManager;
import World;
import MessageManager;
import haxe.ds.HashMap;
import Unit.UnitType;
import hxd.Rand;

final messageManager = MessageManager.singleton;

@:allow(AI)
class GameState implements MessageListener {

    public var world: World;
    public var hexSet(get, never): Set<Hex>;
    public var hexes(get, never): Array<Hex>;
    public var pathfinder(get, never): Astar;
    public var units: Array<Unit>;
    public var hexToUnits: HashMap<Hex, {town:Unit, knight:Unit}>;
    public var currentPlayer: Int;
	public var divineRight: Map<Int, Int>;
    public var land: Map<Int, Int>;
    public var eliminated: Map<Int, Bool>;
	var territories:HashMap<Hex, {owner: Int, dist: Int}>;
    public var humanPlayer: Int;

    public function new(generate=true) {
        if (!generate) return;
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
			var town = new Unit(UnitType.Town, owner_id, h, h);
			var knight = new Unit(UnitType.Knight, owner_id, h, h);
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

    // clone constructor used by AI to look ahead in moves
    function clone(): GameState {
        var gs = new GameState(false);
        // world is never written to outside worldgen, so fine to be shallow reference
        // ditto hex keys later
		gs.world = world; 
        // primitive types, no clone needed
        gs.currentPlayer = currentPlayer;
        gs.humanPlayer = humanPlayer;
        // deep cloning starts
		gs.hexToUnits = new HashMap<Hex, {town: Unit, knight: Unit}>();
		for (h in world.hexes)
			gs.hexToUnits[h] = {town: null, knight: null};
		gs.units = new Array<Unit>();
        for (u in units) {
			var gsu = u.clone();
            gs.units.push(gsu);
			if (gsu.type == Knight)
				gs.hexToUnits[gsu.position].knight = gsu;
            else
				gs.hexToUnits[gsu.position].town = gsu;
        }
		gs.divineRight = new Map<Int, Int>();
        for (p => dr in divineRight)
			gs.divineRight[p] = dr;
		gs.land = new Map<Int, Int>();
        for (p => l in land)
			gs.land[p] = l;
		gs.eliminated = new Map<Int, Bool>();
        for (p => e in eliminated)
            gs.eliminated[p] = e;
		gs.territories = new HashMap<Hex, {owner: Int, dist: Int}>();
        for (h => od in territories)
            gs.territories[h] = {owner: od.owner, dist: od.dist}
        return gs;
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
		if (to_knight != null && to_knight != from_knight && !canAttack(from, to))
            return false;
        return true;
    }

	public function canAttack(from:Hex, to:Hex):Bool {
		// has to be somewhere to attack to\from
		if (!(hexSet.exists(to) && hexSet.exists(from)))
			return false;
        // can't attack ourself
		if (from.equals(to))
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
            moveKnight(from, to);
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
            return true;
        }
        return false;
	}

    function moveKnight(from: Hex, to: Hex, silent=false, tire=true) {
        trace("moveKnight", from, to);
		if (canAttack(from, to)) {
			var unit = hexToUnits[to].knight;
			var back = to.add(to.subtract(from));
			unit.position = back;
            hexToUnits[back].knight = unit;
			if (hexToUnits[back].town != null && hexToUnits[back].town.owner != unit.owner)
				conquerTown(back, unit.owner, silent, true);
		}
		var unit = hexToUnits[from].knight;
		unit.position = to;
		unit.canMove = !tire;
		hexToUnits[unit.position].knight = unit;
        if (!from.equals(to))
		    hexToUnits[from].knight = null;
		if (hexToUnits[to].town != null && hexToUnits[to].town.owner != unit.owner)
			conquerTown(to, unit.owner, silent);
		// else branch just to prevent Recalc being called twice, as double tweens can look glitchy
		else if (!silent) 
			messageManager.sendMessage(new RecalculateTerritoriesMessage());
    }

	function get_hexSet():Set<Hex> {
		return world.hexSet;
	}

	public function determineTerritories() : HashMap<Hex, {owner: Int, dist: Int}> {
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
		var delay = 0.0;
		var moves = AI.aiTurn(clone());
        for (i in 0...moves.length) {
			tweenManager.add(new DelayedCallTween(() -> messageManager.sendMessage(moves[i]), -delay, 0));
			delay += 1.0;
            // double delay for penultimate move, to give a beat and let tweens complete
			if (i == moves.length - 2 || moves.length == 1)
			    delay += 1.0;
		}
    }

    // whether player can buy a castle from another. hex to check 
    // if there's a foreign knight occupying the town, in which case disallow
	public function canBuy(buyer:Int, buyee:Int, hex: Hex) : Bool {
		trace("canBuy", divineRight[buyer] >= 2 * land[buyee], (hexToUnits[hex].knight == null || hexToUnits[hex].knight.home.equals(hex)));
		return divineRight[buyer] >= 2 * land[buyee]
			&& (hexToUnits[hex].knight == null || hexToUnits[hex].knight.home.equals(hex));
	}

	function buyTown(hex:Hex, buyer:Int, silent=false) {
        var town = hexToUnits[hex].town;
        var cost = land[town.owner];
        divineRight[buyer] -= 2*cost;
		conquerTown(hex, buyer, silent);
    }
    
	function conquerTown(hex:Hex, buyer:Int, silent=false, skipRecalc=false) {
        trace("conquer town", hex);
		var town = hexToUnits[hex].town;
		var previous_owner = town.owner;
		town.owner = buyer;
		for (u in units)
			if (u.type == Knight && u.home.equals(hex)) {
                u.owner = buyer;
                u.canMove = false;
                // check if newly converted knight is in a castle, if so conquer it
				if (hexToUnits[hex].town != null && hexToUnits[hex].town.owner != buyer)
					conquerTown(hexToUnits[hex].town.position, buyer, silent, true);
                if (!silent)
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
		if (!silent && !skipRecalc)
            messageManager.sendMessage(new RecalculateTerritoriesMessage());
    }
}
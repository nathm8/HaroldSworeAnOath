import hxd.Rand;
import haxe.ds.HashMap;
import Set;

final 

class UnitPositionPlayer {
	public var position:Hex;
	public var player:Int;
	public var distance:Int;
	public function new(position:Hex, player:Int, distance:Int) {
		this.position = position;
		this.player = player;
		this.distance = distance;
	}
}

class World{
	public var hexes:  Array<Hex>;
	var hexSet:        Set<Hex>;
	var size:          Int;
	var numberPlayers: Int;
	var pathfinder:    Astar;
	var maxD:          Int;
    
    public function new(size: Int, num_players: Int) {
        this.size = size;
        numberPlayers = num_players;
        hexes = [];
    }

	public function generateWorld() {
        // generate hex spiral with noisey heights
        var heightmap = new HashMap<Hex, Float>(); // Hex to z
		var watermap = new HashMap<Hex, Bool>(); // Hex to bool, true for water
        var noise_map = new Noisemap();
        var max_height = 0.0;
        var min_height = 10.0;
        var origin_hex = new Hex(0, 0, 0);
		var spiral = origin_hex.spiral(size);
		var noise_size = Math.max(spiral[spiral.length - 1].toPixel().x, spiral[spiral.length - 1].toPixel().y);
		for (h in spiral) {
            var p = h.toPixel();
            // if noisemap is sampled at negative numbers creates a discontinuity, so move origin to 500,500
			var z = noise_map.getNoiseAtPoint(p.x+500, p.y+500, noise_size);
			if (z > max_height)
				max_height = z;
			if (z < min_height)
				min_height = z;
            heightmap.set(h, z);
        }
        // normalise height data and determine water hexes
        for (h in spiral) {
			var is_water = heightmap.get(h) < 0.5;
            watermap.set(h, is_water);
        }

        // BFS to find largest subgraph (landmass)
		var searched_hexes = new Set<Hex>();
        function bfs(h: Hex, subgraph: Array<Hex>): Array<Hex> {
            // edge cases: out of bounds, been examined already, is water
            if (!heightmap.exists(h)) {
                // trace(h+" not in range");
                return subgraph;
            }
			if (searched_hexes.exists(h)) {
                // trace(h+"already searched");
                return subgraph;
            }
            searched_hexes.add(h);
            if (watermap.get(h)) {
                // trace(h+"is water");
                return subgraph;
            }

            // base case: add current hex to subgraph, recurse to neighbours
            subgraph.push(h);
			for (n in h.ring(1))
            {
                // trace("recursing to neighbours");
                subgraph = bfs(n, subgraph);
            }
            return subgraph;
        }

        // get all continuous landmasses through bfs
        var subgraphs: Array<Array<Hex>> = [];
        for (h in spiral) {
            subgraphs.push(bfs(h, []));
        }

        // get largest continuous landmass
        var largest_subgraph_index = 0;
        var largest_subgraph_length:Float = subgraphs[0].length;
        for (i in 1...subgraphs.length) {
            if (subgraphs[i].length > largest_subgraph_length) {
                largest_subgraph_length = subgraphs[i].length;
                largest_subgraph_index = i;
            }
        }
        hexes = subgraphs[largest_subgraph_index];

        // make the centre of gravity into the origin, also get extrema
        // for different worldgen animation strategies
        var centre_of_gravity = new Hex(0, 0, 0);
		for (h in hexes)
            centre_of_gravity = centre_of_gravity.add(h);
		var translate = centre_of_gravity.scale(1.0 / largest_subgraph_length).round();
        var hexes_tmp = [];
		maxD = 0;
        var h_origin = new Hex(0, 0, 0);
		for (h in hexes) {
            var h_translated = h.subtract(translate);
            hexes_tmp.push(h_translated);
            var d = h_origin.distance(h_translated);
			maxD = d > maxD ? Math.round(d) : maxD;
        }
        
        // set our member properties
        hexes = hexes_tmp;
        hexSet = new Set<Hex>(hexes);
        pathfinder = new Astar(hexSet);
    }

    // use spiral for nice animation
    public function sortHexesSpirally() {
        var hexes_tmp = [];
        var h_origin = new Hex(0, 0, 0);
		for (h in h_origin.spiral(maxD))
			if (hexSet.exists(h))
				hexes_tmp.push(h);
        hexes = hexes_tmp;
    }

	// use directions for nice animation
	public function sortHexesByDirection(opt:{?q:Bool, ?r:Bool, ?s:Bool, ?reversed:Bool}) {
        var s = opt.s;
        var q = opt.q;
        var r = opt.r;
		var reversed = opt.reversed;
        if (!(q || r || s) ) {
			trace("sortHexesByDirection called with no direction");
            return;
        }
        var f: (Hex, Hex) -> Int;
        if (q) {
            if (reversed)
                f = (a, b) -> Math.round(b.q - a.q);
            else
                f = (a, b) -> Math.round(a.q - b.q);
        }
        else if (r) {
            if (reversed)
                f = (a, b) -> Math.round(b.r - a.r);
            else
                f = (a, b) -> Math.round(a.r - b.r);
        }
        else {
            if (reversed)
                f = (a, b) -> Math.round(b.s - a.s);
            else
                f = (a, b) -> Math.round(a.s - b.s);
        }
		hexes.sort(f);
	}

	// shuffle for nice? animation
	public function sortHexesRandomly() {
        var r = Rand.create();
		r.shuffle(hexes);
	}

    // generate starting locations, returning empty array if we fail 1000
    // times. Should consider world invalid and regen.
    public function placeCapitols(): Array<Hex> {
        var min_dist = Math.max(8, size / numberPlayers);

        // all non-coastal locations are valid starting locations
        var available_world: Array<Hex> = [];
        for (h in hexes) {
            var no_water_neighbour = true;
            for (n in h.ring(1))
                if (!hexSet.exists(n)) {
					no_water_neighbour = false;
                    break;
                } 
            if (no_water_neighbour) available_world.push(h);
        }

        var available_world_original = available_world;

        var taken_positions: Array<Hex> = [];
        var attempts = 0;

        while (taken_positions.length != numberPlayers) {
            // look for a spot
			var i = Rand.create().random(available_world.length);
            // trace(i);
            var pos = available_world[i];
            // trace(pos);
            taken_positions.push(pos);
            var available_world_tmp = [];
            for (h in available_world) {
                var dist = pathfinder.findPath(pos, h).length;
                trace(dist);
                if (dist > min_dist) available_world_tmp.push(h);
            }
            available_world = available_world_tmp;
            // if we can't place all players try again from the top, with a limit of the number of times we attempt
            if (available_world.length < numberPlayers - i) {
                // trace(i);
                // trace(taken_positions);
                i = 0;
                // trace(i);
                taken_positions = [];
                available_world = available_world_original;
                attempts++;
                if (attempts == 1000) {
                    trace('Failure to place capitols');
                    return [];
                }
            }
        }

        var player_starting_positions: Array<Hex> = [];
        for (i in 0...numberPlayers) player_starting_positions.push(taken_positions[i]);
        return player_starting_positions;
    }

    // returns:
    //          map of Hex to int, the owning player's index. With -1 for neutral hexes
    //          map of the closest unit to each owned hex, for animation purposes
    public function determineTerritories(units_per_player: HashMap<Hex, Unit>): {owner: HashMap<Hex, Int>, closest: HashMap<Hex, Hex>} {
        
        var territories = new HashMap<Hex, Int>();
        var closest_units = new HashMap<Hex, Hex>();
        for (h in hexes) {
            var bh: PriorityQueue<UnitPositionPlayer> = new PriorityQueue();
            for (unit_position => unit in units_per_player) {
                var d = pathfinder.findPath(h, unit_position).length;
                bh.push(new UnitPositionPlayer(unit_position, unit.owner, d), d);
            }
            var min_dist_player = -1;

            var closest: UnitPositionPlayer = bh.pop();
            var second_closest = bh.pop();
            if (closest == null) {
                trace(false);
                trace(units_per_player);
            }
            if (second_closest == null) {
                trace(false);
                trace(units_per_player);
            }
            var only_one_closest_single_player = true;
            // if the two closest units are equidistant and not on the same side then the hex is neutral
            while (closest.distance == second_closest.distance && only_one_closest_single_player) {
                only_one_closest_single_player = closest.player == second_closest.player;
                if (bh.size() == 0) break;
                second_closest = bh.pop();
            }
            if (only_one_closest_single_player) min_dist_player = closest.player;

            closest_units.set(h, closest.position); // doesn't matter if it's a neutral hex or not here, since it's just for graphics
            territories.set(h, min_dist_player);
        }

        return {owner: territories, closest: closest_units};
    }
}
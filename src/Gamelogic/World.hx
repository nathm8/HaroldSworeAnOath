import hxd.Rand;
import haxe.ds.HashMap;
import Set;

class OwnerDist {
	public var dist:Int;
	public var owner:Int;

	public function new(o:Int, d:Int) {
		dist = d;
		owner = o;
	}
}

class World{
	public var hexes:  Array<Hex>;
	public var hexSet(get, default): Set<Hex>;
	var size:          Int;
	public var pathfinder(default, null):    Astar;
	var maxD:          Int;
    
    public function new(size: Int) {
        this.size = size;
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
			for (n in h.ring(1)) {
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
        if (q) 
            if (reversed)
                f = (a, b) -> Math.round(b.q - a.q);
            else
                f = (a, b) -> Math.round(a.q - b.q);
        else if (r) 
            if (reversed)
                f = (a, b) -> Math.round(b.r - a.r);
            else
                f = (a, b) -> Math.round(a.r - b.r);
        else 
            if (reversed)
                f = (a, b) -> Math.round(b.s - a.s);
            else
                f = (a, b) -> Math.round(a.s - b.s);
		hexes.sort(f);
	}

	// shuffle for nice? animation
	public function sortHexesRandomly() {
        var r = Rand.create();
		r.shuffle(hexes);
	}

    // put down N towns
    public function placeTowns(): Array<Hex> {
        var town_locations = new Array<Hex>();

        var available_world = new Set<Hex>();
        // all non-coastal locations are valid starting locations
        for (h in hexes) {
            var no_water_neighbour = true;
        for (n in h.ring(1))
            if (!hexSet.exists(n)) {
                no_water_neighbour = false;
                break;
            } 
            if (no_water_neighbour) available_world.add(h);
        }
		while (town_locations.length < 30 && available_world.length > 0) {
            var available_array = available_world.toArray();
			var i = Rand.create().random(available_array.length);
            var h = available_array[i];
            town_locations.push(h);
            for (n in h.spiral(2))
                available_world.remove(n);
        }

        return town_locations;
    }

    // returns:
    //          map of Hex to int, the owning player's index. With -1 for neutral hexes
    //          map of the closest unit to each owned hex, for animation purposes
    public function determineTerritories(units: Array<Unit>): HashMap<Hex, OwnerDist> {
        // trace("determineTerritories : start");
		var territories = new HashMap<Hex, OwnerDist>();
        for (h in hexes) {
            var min_d = 100;
            var closest_units = [];
            var visited_hexes = new Set<Hex>();
            for (u in units) {
                if (visited_hexes.exists(u.position)) continue;
				visited_hexes.add(u.position);
                if (u.position.equals(h)) {
					closest_units = [u];
					min_d = 0;
                    break;
                }
                // do quick check first, path length can only be longer than straight line
                var d = h.distance(u.position);
                if (d > min_d) continue;
				var d = pathfinder.findPath(h, u.position).length;
                if (d < min_d) {
                    closest_units = [u];
                    min_d = d;
                } else if (d == min_d) {
                    closest_units.push(u);
                }
            }
            var same_owner = true;
            var owner = closest_units[0].owner;
            for (u in closest_units)
                if (u.owner != owner)
                    same_owner = false;
            if (!same_owner) owner = -1;
            territories[h] = new OwnerDist(owner, min_d);
        }
		return territories;
    }

	function get_hexSet():Set<Hex> {
		return hexSet;
	}
}
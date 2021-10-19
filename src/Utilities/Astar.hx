import haxe.ds.HashMap;

function reconstructPath(from:HashMap<Hex, Hex>, node:Hex):Array<Hex> {
	var path = [node];
	while (from.exists(node)) {
		node = from.get(node);
		path.push(node);
	}
	return path;
}

function heuristic(start:Hex, end:Hex) {
	return start.distance(end);
}

class Astar {
    var hexSet: Set<Hex>;

    public function new(hex_set: Set<Hex>) {
        this.hexSet = hex_set;
    }

	public function findPath(start: Hex, goal: Hex, debug=false): Array<Hex> {
		if (debug) {
			trace('start', start);
			trace('goal', goal);
		}
		if (!this.hexSet.exists(goal)) {
			if (debug)
				trace('goal hex not in world');
			return [];
		}
		
		var open = new Set<Hex>();
		open.add(start);
		
		var closed = new Set<Hex>();
		
		var from = new HashMap<Hex, Hex>();
		
		var gScore = new HashMap<Hex, Int>();
		gScore.set(start, 0);
		
		var frontier = new PriorityQueue<Hex>();
		frontier.push(start, heuristic(start, goal));
		while (open.length > 0) {
			
			var current = frontier.pop();
			if (debug) {
				trace('current', current);
				trace('closed', closed);
			}
			if (current == goal) {
				
				var path = reconstructPath(from, current);
				return path;
			}
			open.remove(current);
			closed.add(current);
			for (h in current.ring(1)) {
				if (debug)
					trace(h);
				if (!this.hexSet.exists(h)) {
					if (debug)
						trace('neighbour not in world, discarding');
					return [];
				}
				if (closed.exists(h)) {
					if (debug)
						trace('neighbour in closed, discarding');
					return [];
				}
				
				var g_tmp = gScore.get(current) + 1;
				if (!open.exists(h))
					open.add(h);
				else if (gScore.exists(h) && g_tmp >= gScore.get(h))
					return [];
				from.set(h, current);
				gScore.set(h, g_tmp);
				frontier.push(h, g_tmp + heuristic(h, goal));
			}
		}
		// exhausted open without finding a path
		if (debug)
			trace('exhausted open without finding a path');
		return [];
	}
}
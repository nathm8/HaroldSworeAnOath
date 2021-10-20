import PriorityQueue;
import haxe.ds.HashMap;

function reconstructPath(from:HashMap<Hex, Hex>, node:Hex):Array<Hex> {
	var path = [node];
	while (from.exists(node)) {
		node = from.get(node);
		path.push(node);
	}
	return path;
}

function heuristic(start:Hex, end:Hex) : Float {
	return start.distance(end);
}

class Astar {
    var hexSet: Set<Hex>;

    public function new(hex_set: Set<Hex>) {
        this.hexSet = hex_set;
    }

	public function findPath(start: Hex, goal: Hex, debug=false): Array<Hex> {
		if (debug) trace("findPath start");
		var frontier = new RePriorityQueue<Hex>(true);
		frontier.push(start, 0);
		var from = new HashMap<Hex, Hex>();
		var costs = new HashMap<Hex, Float>();
		costs[start] = 0;

		while (frontier.size() > 0) {
			var current = frontier.pop();
			if (current.equals(goal)) {
				if (debug) trace("path found");
				return reconstructPath(from, current);
			}
			for (n in current.ring(1)) {
				if (! hexSet.exists(n)) continue;
				var new_cost = costs[current] + 1;
				if (!costs.exists(n) || new_cost < costs[n]) {
					costs[n] = new_cost;
					from[n] = current;
					frontier.pushOrReprioritise(n, new_cost + heuristic(n, goal));
				}
			}
		}

		if (debug) trace("failed to find path");
		return [];
	}
}
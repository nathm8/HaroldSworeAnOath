import MessageManager;

class AI {

    public static function aiTurn(gs: GameState) {
        var moves = new Array<Message>();
        for (u in gs.units) {
			if (u.owner != gs.currentPlayer) continue;
            if (u.type != Knight) continue;
			var moves_priorities = new PriorityQueue<Hex>();
            for (n in u.position.ring(1)) {
				if (!gs.hexSet.exists(n)) continue;
                // attacking enemies a priority
				if (gs.canAttack(u.position, n))
                    moves_priorities.push(n, 1);
                // defending our town high priority
				if (gs.hexToUnits[n].town != null && gs.hexToUnits[n].town.owner == gs.currentPlayer) {
                    for (tn in n.ring(1))
						if (gs.hexToUnits[tn].knight != null && gs.hexToUnits[tn].knight.owner != gs.currentPlayer){
                            moves_priorities.push(n, 10);
                            break;
                        }
                }
                // capturing towns highest priority
				if (gs.canMove(u.position, n)
					&& gs.hexToUnits[n].knight == null
					&& gs.hexToUnits[n].town != null
					&& gs.hexToUnits[n].town.owner != gs.currentPlayer)
                    moves_priorities.push(n, 100);
            }
            // if we have a priority move take it
            if (moves_priorities.size() > 0) {
				var m = moves_priorities.pop();
				moves.push(new AIMoveMessage(u.position, m));
                gs.moveKnight(u.position, m, true);
            }
            // otherwise move towards nearest enemy unit
            else {
                var no_move = true;
                var min_d = 100;
                var n = new Hex(0,0,0);
				for (e in gs.units) {
					if (e.owner == gs.currentPlayer)
						continue;
					var path = gs.pathfinder.findPath(u.position, e.position);
					if (path.length > 1 && path.length < min_d && gs.canMove(u.position, path[path.length-2])) {
						min_d = path.length;
						n = path[path.length-2];
						no_move = false;
                    }
                }
                if (no_move) continue;
				moves.push(new AIMoveMessage(u.position, n));
                gs.moveKnight(u.position, n, true);
            }
        }
        // create priority queue of (town, cost)
        // go through all buy all the towns we can, most expensive first
        // then do another round of troop movement
        var player_land = new Array<{land:Int, player:Int}>();
		for (p => l in gs.land) player_land.push({land:l, player:p});
        player_land.sort((a,b) -> a.land-b.land );
        var dr = gs.divineRight[gs.currentPlayer];

        var biggest = new PriorityQueue<Unit>();
		for (u in gs.units) {
			if (u.type == Town && u.owner != gs.currentPlayer && 2*gs.land[u.owner] <= dr)
				biggest.push(u, gs.land[u.owner]);
        }
        while (biggest.size() > 0) {
            var town = biggest.pop();
            var cost = gs.land[town.owner];
			if (cost > dr) break;
			dr -= 2 * cost;
            if (gs.canBuy(gs.currentPlayer, town.owner, town.position)) {
                moves.push(new BuyTownMessage(town.position, gs.currentPlayer));
                gs.buyTown(town.position, gs.currentPlayer, true);
            }
        }

		moves.push(new EndTurnMessage());
        return moves;
    }
}
import MessageManager;

class AI {

    public static function aiTurn(gs: GameState) {
        // trace("AI turn start", gs.currentPlayer);
        var moves = new Array<Message>();
        for (u in gs.units) {
			if (u.owner != gs.currentPlayer) continue;
            if (u.type != Knight) continue;
			var moves_priorities = new PriorityQueue<Hex>();
            var adjacent_enemies = 0;
            for (n in u.position.ring(1)) {
				if (!gs.hexSet.exists(n)) continue;
                // attacking enemies a priority
				if (gs.canMove(u.position, n) && gs.canAttack(u.position, n)) {
                    moves_priorities.push(n, 1);
					adjacent_enemies++;
                }
                // defending our town high priority
				if (gs.hexToUnits(n).town != null && gs.hexToUnits(n).town.owner == gs.currentPlayer) {
                    for (tn in n.ring(1))
						if (gs.hexToUnits(tn).knight != null && gs.hexToUnits(tn).knight.owner != gs.currentPlayer && gs.canMove(u.position, n)){
                            moves_priorities.push(n, 10);
                            break;
                        }
                }
                // capturing towns highest priority
				if (gs.canMove(u.position, n)
					&& gs.hexToUnits(n).knight == null
					&& gs.hexToUnits(n).town != null
					&& gs.hexToUnits(n).town.owner != gs.currentPlayer)
                    moves_priorities.push(n, 100);
            }
			// garrisoning our town high priority
			if (adjacent_enemies >= 2 && gs.hexToUnits(u.position).town != null && gs.canMove(u.position, u.position))
				moves_priorities.push(u.position, 20);
            // if we have a priority move take it
            if (moves_priorities.size() > 0) {
				var h = moves_priorities.pop();
				moves.push(new AIMoveMessage(u.position, h));
                gs.moveKnight(u.position, h, true);
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
        // go through and buy all the towns we can, most expensive first
        var biggest = new PriorityQueue<Unit>();
		for (u in gs.units) {
			if (u.type == Town && gs.canBuy(gs.currentPlayer, u.owner, u.position))
				biggest.push(u, 2*gs.land[u.owner]);
        }
        while (biggest.size() > 0) {
            var town = biggest.pop();
            var cost = 2.5*gs.land[town.owner]+5; // we don't recalc land after moving knights, so have some slack
			if (cost > gs.divineRight[gs.currentPlayer]) continue;
			if (gs.canBuy(gs.currentPlayer, town.owner, town.position)) {
				moves.push(new AIBuyTownMessage(town.position, gs.currentPlayer));
                gs.buyTown(town.position, gs.currentPlayer, true);
            }
        }

		moves.push(new EndTurnMessage());
        return moves;
    }
}
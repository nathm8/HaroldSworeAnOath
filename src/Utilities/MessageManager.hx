class Message {
	public var name(get, null) = "Message";

	function get_name(): String {
		return name;
	}
}

class HexClickMessage extends Message {
    
    public var hex: Hex;
    
	public function new(h:Hex) {
        name = "HexClickMessage";
		hex = h;
	}
}

class HexOverMessage extends Message {
	public var hex:Hex;

	public function new(h:Hex) {
		name = "HexOverMessage";
		hex = h;
	}
}

class KnightMoveMessage extends Message {
	public var fromHex:Hex;
	public var toHex:Hex;

	public function new(f:Hex, t:Hex) {
		name = "KnightMoveMessage";
		fromHex = f;
		toHex = t;
	}
}

class RecalculateTerritoriesMessage extends Message {
	public function new() {
		name = "RecalculateTerritoriesMessage";
	}
}

class UpdateEconomyGUIMessage extends Message {
	public var instant: Bool;
	public function new(i = false) {
		instant = i;
		name = "UpdateEconomyGUIMessage";
	}
}

class EndTurnMessage extends Message {
	public function new() {
		name = "EndTurnMessage";
	}
}

class AIEndTurnMessage extends Message {
	public function new() {
		name = "AIEndTurnMessage";
	}
}

class HumanEndTurnMessage extends Message {
	public function new() {
		name = "HumanEndTurnMessage";
	}
}

class StandUpMessage extends Message {
	public var unit:Unit;
	public function new(u:Unit) {
		unit = u;
		name = "StandUpMessage";
	}
}

class UpdateKnightColourMessage extends Message {
	public var unit:Unit;
	public function new(u:Unit) {
		unit = u;
		name = "UpdateKnightColourMessage";
	}
}

class BuyTownMessage extends Message {
	public var hex:Hex;
	public var player:Int;
	public function new(h:Hex, p:Int) {
		hex = h; player=p;
		name = "BuyTownMessage";
	}
}
class AIBuyTownMessage extends Message {
	public var hex:Hex;
	public var player:Int;
	public function new(h:Hex, p:Int) {
		hex = h; player=p;
		name = "AIBuyTownMessage";
	}
}

class AIMoveMessage extends Message {
	public var fromHex:Hex;
	public var toHex:Hex;

	public function new(f:Hex, t:Hex) {
		name = "AIMoveMessage";
		fromHex = f;
		toHex = t;
	}
}

class AIVictoryMessage extends Message {
	public var player:Int;

	public function new(p: Int) {
		name = "AIVictoryMessage";
		player = p;
	}
}

class HumanVictoryMessage extends Message {
	public var player:Int;

	public function new(p: Int) {
		name = "HumanVictoryMessage";
		player = p;
	}
}

class HumanDefeatMessage extends Message {
	public var player:Int;

	public function new(p: Int) {
		name = "HumanDefeatMessage";
		player = p;
	}
}

interface MessageListener {
    public function receiveMessage(msg: Message): Bool;
}

class MessageManager {

    var listeners: Array<MessageListener>;
	public static final singleton = new MessageManager();

    private function new() {
		listeners = [];
    }

	public function addListener(l:MessageListener) {
		listeners.push(l);
    }

    public function sendMessage(msg: Message) {
        for (l in listeners)
            if (l.receiveMessage(msg)) return;
		// trace("unconsumed message", msg);
    }

	public function reset() {
		listeners = [];
	}

}
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
    }

}
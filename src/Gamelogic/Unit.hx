enum UnitType {
	Knight;
	Town;
}

class Unit {
    public var type: UnitType;
	public var owner: Int;
	public var liege: Int;
	public var canMove: Bool;
    public var position: Hex;
    static var nextId=0;
    var id: Int;

	public function new(type:UnitType, owner:Int, position: Hex, canMove = true) {
        this.type = type;
        this.owner = owner;
        this.canMove = canMove;
        this.position = position;
        id = nextId++;
    }

    public function hashCode(): Int {
        return id;
    }
}

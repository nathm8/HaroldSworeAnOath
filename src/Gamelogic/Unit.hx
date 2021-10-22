enum UnitType {
	Knight;
	Town;
}

class Unit {
    public var type: UnitType;
	public var owner: Int;
	public var home: Unit;
	public var canMove: Bool;
    public var position: Hex;

	public function new(type:UnitType, owner:Int, position: Hex, home=null, canMove = true) {
        this.type = type;
        this.owner = owner;
        this.canMove = canMove;
        this.position = position;
        this.home = home;
    }

    public function clone(): Unit {
		return new Unit(type, owner, position, home, canMove);
    }

}

import UnitTypes.UnitType;

final unit_cost = [
    UnitType.Sword => 3,
    UnitType.Cavalry => 5,
    UnitType.Pike => 3,
    UnitType.Musket => 7
];
final unit_movement = [
    UnitType.Sword => 4,
    UnitType.Cavalry => 6,
    UnitType.Pike => 4,
    UnitType.Musket => 4
];

// combat results
enum CombatResult {
    Victory;
    Defeat;
    Draw;
    AttackCapitol;
}

class Unit {
    public var type: UnitType;
	public var owner: Int;
	public var canMove: Bool;
    public var position: Hex;

    public function new(type: UnitType, owner: Int, position: Hex, canMove = false) {
        this.type = type;
        this.owner = owner;
        this.canMove = canMove;
        this.position = position;
    }
}

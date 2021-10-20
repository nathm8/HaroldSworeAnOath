final pointyLayout = {
	orientation: {
		f0: Math.sqrt(3.0),
		f1: Math.sqrt(3.0) / 2.0,
		f2: 0.0,
		f3: 3.0 / 2.0,
		b0: Math.sqrt(3.0) / 3.0,
		b1: -1.0 / 3.0,
		b2: 0.0,
		b3: 2.0 / 3.0,
		startAngle: 0.5
	},
	size: {x: 11.5, y: 10.6},
	origin: {x: 500, y: 500}
}

class Hex{
    public var q:Float;
	public var r:Float;
	public var s:Float;

	public static var directions = [
		new Hex(1, 0, -1),
		new Hex(1, -1, 0),
		new Hex(0, -1, 1),
		new Hex(-1, 0, 1),
		new Hex(-1, 1, 0),
		new Hex(0, 1, -1),
	];

	public function new(q, r, s) {
		this.q = q;
		this.r = r;
		this.s = s;
	}

	public function toString() : String {
		return "Hex("+q+","+r+","+s+")";
	}

	public function hashCode():Int {
		var hq = Math.round(q);
		var hr = Math.round(r);
		return hq ^ (hr + 0x9e3779b9 + (hq << 6) + (hq >> 2));
	}

	@:op(A == B) 
	public function equals(other:Hex) : Bool {
		return this.q == other.q && this.r == other.r && this.s == other.s;
	}

	@:op(A + B) 
	public function add(rhs:Hex) : Hex {
		return new Hex(this.q + rhs.q, this.r + rhs.r, this.s + rhs.s);
	}

	@:op(A - B) 
	public function subtract(rhs:Hex) : Hex {
		return new Hex(this.q - rhs.q, this.r - rhs.r, this.s - rhs.s);
	}

	@:op(A * B) 
	public function scale(rhs:Float) : Hex {
		return new Hex(this.q * rhs, this.r * rhs, this.s * rhs);
	}

	public function distance(other:Hex) : Float {
		return this.subtract(other).length();
	}

	public function length() : Float {
		return (Math.abs(this.q) + Math.abs(this.r) + Math.abs(this.s)) / 2;
	}

	public function round():Hex
	{
		var qi = Math.round(this.q);
		var ri = Math.round(this.r);
		var si = Math.round(this.s);
		var q_diff = Math.abs(qi - this.q);
		var r_diff = Math.abs(ri - this.r);
		var s_diff = Math.abs(si - this.s);
		if (q_diff > r_diff && q_diff > s_diff) {
			qi = -ri - si;
		} else if (r_diff > s_diff) {
			ri = -qi - si;
		} else {
			si = -qi - ri;
		}
		return new Hex(qi, ri, si);
	}

	public static function direction(direction:Int) : Hex {
		return Hex.directions[direction];
	}

	public function ring(radius:Int) : Array<Hex> {
		var results = [];
		var hex = this.add(Hex.direction(4).scale(radius));
		for (i in 0...6) {
			for (j in 0...radius) {
				results.push(hex);
				hex = hex.neighbor(i);
			}
		}
		return results;
	}

	public function spiral(radius:Int) {
		var results = [this];
		for (k in 1...radius) {
			results = results.concat(this.ring(k));
		}
		return results;
	}

	public function neighbor(direction:Int) : Hex {
		return this.add(Hex.direction(direction));
	}

	public function toPixel(layout=null) {
		if (layout == null)
			layout = pointyLayout;
		var M = layout.orientation;
		var size = layout.size;
		var origin = layout.origin;
		var x = (M.f0 * this.q + M.f1 * this.r) * size.x;
		var y = (M.f2 * this.q + M.f3 * this.r) * size.y;
		return {x: x + origin.x, y: y + origin.y};
	}
}

// @:forward(q, r, s)
// abstract Hex(HexBase) {
    
// 	public function new(q, r, s) {
// 		this.q = q;
// 		this.r = r;
// 		this.s = s;
// 	}

//     public function toString() : String {
// 		return "Hex(" + this.q + ", " + this.r + ", " + this.s+")";
//     }

//     @:op(A == B) public function equals(other:Hex) : Bool {
// 		return this.q == other.q && this.r == other.r && this.s == other.s;
//     }

//     @:op(A + B) public function add(rhs:Hex) : Hex {
// 		return new Hex(this.q + rhs.q, this.r + rhs.r, this.s + rhs.s);
//     }

// 	@:op(A - B) public function subtract(rhs:Hex) : Hex {
// 		return new Hex(this.q - rhs.q, this.r - rhs.r, this.s - rhs.s);
// 	}

// 	@:op(A * B) public function scale(rhs:Int) : Hex {
// 		return new Hex(this.q * rhs, this.r * rhs, this.s * rhs);
// 	}
// }
import haxe.ds.HashMap;

class Set<T:{function hashCode():Int;}> {
	var map:HashMap<T, Bool>;
    public var length(get, null): Int;
	public function new(?items: Iterable<T>) {
		map = new HashMap<T, Bool>();
        if (items != null)
            for (i in items)
                map.set(i, true);
		length = 0;
	}

    public function add(a: T){
        if (map.exists(a)) return;
		length++;
        map.set(a, true);
    }
    
	public function remove(a:T) {
        if (!map.exists(a)) return;
        length--;
        map.remove(a);
    }

	public function exists(a:T) : Bool {
        return map.exists(a);
    }

	public function get_length() : Int {
		return length;
    }
}
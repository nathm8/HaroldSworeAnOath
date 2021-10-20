import haxe.ds.HashMap;
import polygonal.ds.PriorityQueue;


class Item<T> implements polygonal.ds.Prioritizable {
    public var payload: T;
	public var priority(default, null):Float;
	public var position(default, null):Int;

    public function new(object:T, p: Float) {
        payload = object;
        priority = p;
    }
}

class PriorityQueue<T> {

	var internal:polygonal.ds.PriorityQueue<Item<T>>;

	public function new(reverse = false) {
		internal = new polygonal.ds.PriorityQueue<Item<T>>(1, reverse);
	}

	public function push(t:T, priority:Float) {
		var item = new Item<T>(t, priority);
        internal.enqueue(item);
	}

	public function pop():T {
		var t = internal.dequeue().payload;
        return t;
	}

	public function size():Int {
        return internal.size;
    }

}

class RePriorityQueue<T:{function hashCode():Int;}> {
	var internal:polygonal.ds.PriorityQueue<Item<T>>;
	var map:HashMap<T, Item<T>>;

	public function new(reverse = false) {
		internal = new polygonal.ds.PriorityQueue<Item<T>>(1, reverse);
		map = new HashMap<T, Item<T>>();
	}

	public function push(t:T, priority:Float) {
		var item = new Item<T>(t, priority);
		map[t] = item;
		internal.enqueue(item);
	}

	public function pop():T {
		var t = internal.dequeue().payload;
		map.remove(t);
		return t;
	}

	public function size():Int {
		return internal.size;
	}

	public function pushOrReprioritise(t:T, p:Float) {
		if (map.exists(t)) {
			var item = map[t];
			internal.reprioritize(item, p);
		} else
			push(t, p);
	}
}

/*    var items: Array<T>;
    var priorities: Array<Float>;
    // whether to consider the smallest number the priority
	var reverse: Bool;

    public function new(reverse=false) {
        items = new Array<T>();
		priorities = new Array<Float>();
		this.reverse = reverse;
    }

	public function push(item:T, priority:Float) {
        this.items.push(item);
        this.priorities.push(priority);
    }

	public function pop(): T {
        if (this.items.length == 0) return null;
        var max_priority = this.priorities[0];
		var max_priority_item = this.items[0];
        for (i in 0...this.size()) {
			if (!reverse) {
                if (this.priorities[i] > max_priority) {
                    max_priority = this.priorities[i];
                    max_priority_item = this.items[i];
                }
            } else {
				if (this.priorities[i] < max_priority) {
					max_priority = this.priorities[i];
					max_priority_item = this.items[i];
				}
            }
        }
        items.remove(max_priority_item);
		return max_priority_item;
    }

    public function size(): Int {
        return this.items.length;
    }
}
*/
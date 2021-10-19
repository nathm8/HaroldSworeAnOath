class PriorityQueue<T> {
    var items: Array<T>;
    var priorities: Array<Float>;

    public function new() {
        items = new Array<T>();
		priorities = new Array<Float>();
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
            if (this.priorities[i] > max_priority) {
                max_priority = this.priorities[i];
				max_priority_item = this.items[i];
            }
        }
		return max_priority_item;
    }

    public function size(): Int {
        return this.items.length;
    }
}

import h2d.Drawable;

class Tween {
	public function update(dt:Float) {}
}

class TweenManager {
    var tweens: Array<Tween>;
    
	public static final singleton = new TweenManager();

    private function new() {
        tweens = [];
    }

    public function update(dt: Float) {
        for (t in tweens)
            t.update(dt);
    }

    public function add(t: Tween) {
        tweens.push(t);
    }

}
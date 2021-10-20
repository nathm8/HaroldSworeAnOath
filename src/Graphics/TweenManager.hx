import hxd.Rand;
import h2d.Drawable;

class Tween {
    public var timeTotal:Float;
	public var timeElapsed:Float;

    public function new(te:Float, tt:Float) {
		// negative te acts a delay
		timeElapsed = te;
		timeTotal = tt;
	}

	public function update(dt:Float) {
        timeElapsed += dt;
        if (timeElapsed > timeTotal)
            timeElapsed = timeTotal;
    }
}

class ScaleBounceTween extends Tween {
	var drawable:Drawable;
	var x = [0.8, 2.5, 0.5, 1];

	public function new(d:Drawable, te:Float, tt:Float) {
        super(te, tt);
		drawable = d;
		d.visible = false;
	}

	override function update(dt:Float) {
        super.update(dt);
		// negative te acts as a delay
		if (timeElapsed < 0)
			return;
		drawable.visible = true;
		var t = timeElapsed / timeTotal;
		var bx = Math.pow(1 - t, 3) * x[0]
			+ 3 * Math.pow(1 - t, 2) * t * x[1]
			+ 3 * (1 - t) * Math.pow(t, 2) * x[2]
			+ Math.pow(t, 3) * x[3];
		drawable.setScale(bx);
	}
}

class ScaleLinearTween extends Tween {
	var drawable:Drawable;

	public function new(d:Drawable, te:Float, tt:Float) {
		super(te, tt);
		drawable = d;
        d.setScale(0);
	}

	override function update(dt:Float) {
		super.update(dt);
		timeElapsed += Rand.create().rand()/10;
		// negative te acts a delay
		if (timeElapsed < 0)
			return;
		var t = timeElapsed / timeTotal;
		drawable.setScale(t);
        if (t >= 1)
            drawable.setScale(1);
	}
}

class ColourTween extends Tween {

	var drawable:Drawable;
	var originalColour: h3d.Vector;
	var targetColour: h3d.Vector;

	public function new(d:Drawable, orig_col:h3d.Vector, targ_col:h3d.Vector, te:Float, tt:Float) {
		super(te, tt);
		drawable = d;
		originalColour = orig_col;
		targetColour = targ_col;
	}

	override function update(dt:Float) {
		super.update(dt);
		// negative te acts a delay
		if (timeElapsed < 0)
			return;
		var t = timeElapsed / timeTotal;
		var d_col = new h3d.Vector(targetColour.x * t + originalColour.x * (1 - t),
								   targetColour.y * t + originalColour.y * (1 - t),
								   targetColour.z * t + originalColour.z * (1 - t),
								   targetColour.w * t + originalColour.w * (1 - t));
		drawable.color = d_col;
	}
}

class RaiseTween extends Tween {
	var drawable:Drawable;
	var originalY:Float;
	var targetY:Float;

	public function new(d:Drawable, orig:Float, targ:Float, te:Float, tt:Float) {
		super(te, tt);
		drawable = d;
		originalY = orig;
		targetY = targ;
	}

	override function update(dt:Float) {
		super.update(dt);
		// negative te acts a delay
		if (timeElapsed < 0)
			return;
		var t = Math.pow(timeElapsed / timeTotal, 2);
		drawable.y = t*targetY + (1-t)*originalY;
	}
}

class DelayedCallTween extends Tween {
    var func: ()->Void;

	public function new(func:() -> Void, te:Float, tt:Float) {
        super(te, tt);
        this.func = func;
    }

	override function update(dt:Float) {
        super.update(dt);
        if (timeElapsed >= timeTotal)
            func();
    }

}

class TweenManager {
    var tweens: Array<Tween>;
    
	public static final singleton = new TweenManager();

    private function new() {
        tweens = [];
    }

    public function update(dt: Float) {
        var to_remove = [];
        for (t in tweens) {
            t.update(dt);
            if (t.timeElapsed >= t.timeTotal)
                to_remove.push(t);
        }
        for (t in to_remove)
            tweens.remove(t);
    }

    public function add(t: Tween) {
        tweens.push(t);
    }

}
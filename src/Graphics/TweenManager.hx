import h2d.Text;
import h2d.Object;
import js.html.DragEvent;
import hxd.Rand;
import h2d.Drawable;

class Tween {
    public var timeTotal:Float;
	public var timeElapsed:Float;
	public var kill:Bool = true; // flag to let tweens live forever

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
		var t = Math.pow(timeElapsed / timeTotal, 6);
		drawable.y = t*targetY + (1-t)*originalY;
	}
}

class RaiseSmoothTween extends Tween {
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

class MoveBounceTween extends Tween {
	var drawable:Drawable;
	var x = [0, 1.1, 0.7, 1];
	var y = [0, -0.4, 1.5, 1];
	
	var original:{x:Float, y:Float};
	var target:{x:Float, y:Float};

	public function new(d:Drawable, orig:{x:Float, y:Float},  targ: {x:Float, y:Float}, te:Float, tt:Float, retreat=false) {
		super(te, tt);
		drawable = d;
		original = orig;
		target = targ;
		if (retreat){
			x[0] = 1; x[3] = 0;
			y[0] = 1; y[3] = 0;
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		// negative te acts as a delay
		if (timeElapsed < 0)
			return;
		var t = Math.pow(timeElapsed / timeTotal, 5);
		// if (t > 0.5) {
		// 	var tt = timeElapsed / (timeTotal * timeElapsed);
		// 	t = tt > 1 ? 1 : tt;
		// }
		var bx = Math.pow(1 - t, 3) * x[0]
			+ 3 * Math.pow(1 - t, 2) * t * x[1]
			+ 3 * (1 - t) * Math.pow(t, 2) * x[2]
			+ Math.pow(t, 3) * x[3];
		var by = Math.pow(1 - bx, 3) * y[0]
			+ 3 * Math.pow(1 - bx, 2) * bx * y[1]
			+ 3 * (1 - bx) * Math.pow(bx, 2) * y[2]
			+ Math.pow(bx, 3) * y[3];
		drawable.x = (1 - by) * original.x + by*target.x;
		drawable.y = (1 - by) * original.y + by*target.y;
	}
}

class GlowInfiniteTween extends Tween {
	var drawable:Drawable;
	var reverse=false;

	public function new(d:Drawable, te:Float, tt:Float) {
		super(te, tt);
		drawable = d;
		kill = false;
	}

	override function update(dt:Float) {
		dt = reverse ? -dt: dt;
		super.update(dt);
		if (timeElapsed < 0 || timeElapsed >= timeTotal)
			reverse = !reverse;
		var t = timeElapsed / timeTotal;
		drawable.alpha = t;
	}
}

class FadeOutTween extends Tween {
	var obj:Object;

	public function new(o:Object, te:Float, tt:Float) {
		super(te, tt);
		obj = o;
	}

	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		if (t < 0.5)
			t = 0;
		obj.alpha = 1-t;
		if (t == 1)
			obj.remove();
	}
}

class TextTween extends Tween {
	var text:Text;
	var from: Int;
	var to: Int;

	public function new(tex:Text, f: Int, t: Int, te:Float, tt:Float) {
		super(te, tt);
		text = tex;
		to = t;
		from = f;
	}

	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		text.text = Std.string(Math.round(to*t + from*(1-t)));
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
			if (t.kill)
            	tweens.remove(t);
    }

    public function add(t: Tween) {
        tweens.push(t);
    }

    public function remove(t: Tween) {
        tweens.remove(t);
    }

	public function reset() {
		tweens = [];
	}

}
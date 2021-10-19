import h2d.Drawable;
import TweenManager.Tween;

class ScaleBounceTween extends Tween {
    var drawable: Drawable;
    var timeTotal: Float;
    var timeElapsed: Float;
    var x = [0.8, 2.5, 0.5, 1];

    public function new(d: Drawable, te:Float, tt: Float) {
        // negative te acts a delay
        timeElapsed = te;
        timeTotal = tt;
        drawable = d;
    }
    
    override function update(dt: Float) {
        timeElapsed += dt;
		if (timeElapsed > timeTotal) timeElapsed = timeTotal;
        // negative te acts a delay
        if (timeElapsed < 0) return;
		drawable.visible = true;
        var t = timeElapsed/timeTotal;
		var bx = Math.pow(1 - t, 3)*x[0] + 3*Math.pow(1 - t, 2)*t*x[1] + 3*(1 - t)*Math.pow(t, 2)*x[2] + Math.pow(t, 3)*x[3];
        drawable.setScale(bx);
    }
}
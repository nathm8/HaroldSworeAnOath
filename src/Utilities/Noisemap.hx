import hxd.Perlin;

final seeds = [
	483655,
	172512,
	308892,
	381256,
	413795,
	448958];

class Noisemap {
	var noisemap:Array<Array<Float>>;
	var noise = new Perlin();
	var seed = seeds[Std.random(6)];
	
	public function new() {
		noise.normalize = true;
	}

	public function getNoiseAtPoint(x: Float, y: Float, size: Float) : Float {
		function dist(x:Float, y:Float):Float {
			return Math.sqrt(Math.pow(x - size / 2, 2) + Math.pow(y - size/2, 2));
		}

		var max_dist = dist(size, size);

		function dist_scale(x:Float, y:Float):Float {
			return 1 - Math.pow(dist(x, y) / max_dist, 2);
		}

		var n = noise.perlin(seed, x / 64, y / 64, 4, 0.5, 2.0);
		var n2 = noise.perlin(seed, x / 128, y / 128, 8, 0.5, 0.0);
		var n3 = noise.perlin(seed, x / 512, y / 512, 12, 0.5, 2.0);
		var ds = dist_scale(x, y);
		var z = (n - n2 + 2 * n3 + 4) / 8 * ds;
		return z;
    }

	function populateGrid(size : Int) {
		noisemap = [for (x in 0...size) [for (y in 0...size) 0]];

		for (x in 0...size) {
			for (y in 0...size) {
				var z = getNoiseAtPoint(x, y, size);
				noisemap[x][y] = z;
			}
		}

		for (x in 0...size)
			for (y in 0...size) {
				var z = noisemap[x][y];
				var z_thresh = z < 0.5 ? 0 : 1;
				noisemap[x][y] = z_thresh;
			}
	}
}
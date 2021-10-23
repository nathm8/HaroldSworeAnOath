import h2d.Flow;
import hxd.Event;
import h2d.col.Polygon;
import h2d.col.PolygonCollider;
import h2d.col.Polygons;
import h2d.col.Point;
import Constants;
import h2d.Bitmap;
import h2d.Scene;

class MainMenu extends Scene {

    public function new(startGame: ()->Void) {
        super();

        // knight graphics
		var left_tile = hxd.Res.img.MenuKnightLeft.toTile();
        left_tile.setCenterRatio();
        var i = Std.random(7);
        var left = new Bitmap(left_tile, this);
        left.x = width/2;
        left.y = height/5;
        left.color = COLOURS[i];

		var right_tile = hxd.Res.img.MenuKnightRight.toTile();
        right_tile.setCenterRatio();
		var j = Std.random(7);
        while (i==j)
			j = Std.random(7);
		var right = new Bitmap(right_tile, this);
		right.x = width / 2;
		right.y = height / 5;
		right.color = COLOURS[j];
        
        // title
		var titleText = new h2d.Text(hxd.res.DefaultFont.get(), this);
		titleText.x = width / 2;
		titleText.y = height / 3 + 25;
		titleText.text = "Harold Swore An Oath";
		titleText.textAlign = Center;
		titleText.setScale(5);

        // rules
		var rulesTile = hxd.Res.img.Rules.toTile();
		rulesTile.setCenterRatio();
		var rules = new Bitmap(rulesTile, this);
		rules.x = width / 2;
		rules.y = height / 4;
		rules.visible = false;
		rules.color = COLOURS[i];

        // buttons
		var playButtonTile = hxd.Res.img.ButtonBG.toTile();
		playButtonTile.setCenterRatio();
		var playButton = new Bitmap(playButtonTile, this);
		playButton.x = width / 2;
		playButton.y = height / 3 + 200;
        playButton.scale(2);
		playButton.color = COLOURS[i];
		var playButtonText = new h2d.Text(hxd.res.DefaultFont.get(), playButton);
        playButtonText.color = COLOURS[7];
		playButtonText.y = -18;
		playButtonText.text = "Play";
		playButtonText.textAlign = Center;
		playButtonText.scale(2);

		var howButtonTile = hxd.Res.img.ButtonBG.toTile();
		howButtonTile.setCenterRatio();
		var howButton = new Bitmap(howButtonTile, this);
		howButton.x = width / 2;
		howButton.y = height / 3 + 350;
		howButton.scale(2);
		howButton.color = COLOURS[j];
		var howButtonText = new h2d.Text(hxd.res.DefaultFont.get(), howButton);
		howButtonText.color = COLOURS[7];
		howButtonText.y = -18;
		howButtonText.text = "Rules";
		howButtonText.textAlign = Center;
		howButtonText.scale(2);

		var polys:Polygons = new Polygons();
		polys.push(new Polygon([
			new Point(-60, -22.5),
			new Point(60, -22.5),
			new Point(60, 22.5),
			new Point(-60, 22.5)
		]));
		var playInteraction = new h2d.Interactive(0, 0, playButton, new PolygonCollider(polys, true));
		playInteraction.onClick = function(event:Event) {
			startGame();
		};
		var rulesInteraction = new h2d.Interactive(0, 0, howButton, new PolygonCollider(polys, true));
		rulesInteraction.onClick = function(event:Event) {
			left.visible = !left.visible;
			right.visible = !right.visible;
			titleText.visible = !titleText.visible;
			rules.visible = !rules.visible;
			playButton.visible = !playButton.visible;
		};

		var right_polys:Polygons = new Polygons();
		right_polys.push(new Polygon([
			new Point(0, -140),
			new Point(120, -140),
			new Point(120, 140),
			new Point(0, 140)
		]));

		var left_polys:Polygons = new Polygons();
		left_polys.push(new Polygon([
			new Point(0, 140),
			new Point(-120, 140),
			new Point(-120, -140),
			new Point(0, -140)
		]));

		var rightInteraction = new h2d.Interactive(0, 0, right, new PolygonCollider(right_polys, true));
		rightInteraction.onClick = function(event:Event) {
			var old_j = j;
			while (j == old_j || i == j)
				j = Std.random(7);		
			right.color = COLOURS[j];
			howButton.color = COLOURS[j];
		};
		
		var leftInteraction = new h2d.Interactive(0, 0, left, new PolygonCollider(left_polys, true));
		leftInteraction.onClick = function(event:Event) {
			var old_i = i;
			while (i == old_i || i == j)
				i = Std.random(7);
			left.color = COLOURS[i];
			playButton.color = COLOURS[i];
			rules.color = COLOURS[i];
		};
    }
}
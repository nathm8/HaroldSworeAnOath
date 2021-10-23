import h2d.Bitmap;
import TweenManager;
import h2d.Object;
import Constants;
import h2d.Text;

final tweenManager = TweenManager.singleton;

class CostIndicator extends Object {

    public function new(h: Hex, gameScene: GameScene, owner_id: Int, can_buy: Bool) {
        super();
        gameScene.add(this, 90);
        var p = h.toPixel(); x = p.x; y = p.y - 20;
		var cost = new h2d.Text(hxd.res.DefaultFont.get(), this);
		cost.text = Std.string(2*gameScene.gameState.land[owner_id]);
        cost.textAlign = Center;
        cost.color = COLOURS[7];
        if (can_buy)
		    cost.color = COLOURS[gameScene.gameState.currentPlayer];

		var highlightTile = hxd.Res.img.KnightHighlight.toTile();
		highlightTile.setCenterRatio();
		var highlight = new Bitmap(highlightTile);
        var knight_hex = new Hex(0,0,0);
        for (u in gameScene.gameState.units)
            if (u.type == Knight && u.home.equals(h)) {
                knight_hex = u.position;
                break;
            }
		highlight.x = knight_hex.toPixel().x;
		highlight.y = knight_hex.toPixel().y;
		gameScene.add(highlight, 3);

        tweenManager.add(new FadeOutTween(this, 0, 2));
        tweenManager.add(new FadeOutTween(highlight, 0, 2));
    }
}
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

        tweenManager.add(new FadeOutTween(this, 0, 2));
    }
}
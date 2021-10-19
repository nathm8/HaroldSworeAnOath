import h2d.Tile;

class Resource {
    public static var instance = new Resource();

    public var hex(default, null): Tile;
    // public var hex(default, null): Tile;
    // public var hex(default, null): Tile;
    // public var hex(default, null): Tile;
    // public var hex(default, null): Tile;

    private function new() {
        hxd.Res.initEmbed();
		hex = hxd.Res.img.Hex.toTile();
		hex.setCenterRatio();
    }
}

final RESOURCES = Resource.instance;

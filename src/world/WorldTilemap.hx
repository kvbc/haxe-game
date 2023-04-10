package world;

import world.tilemapgen.Main;
import world.tilemapgen.Main.JsonMap;
import haxe.Json;
import math.IntVector2;
import world.tilemapgen.Main.TileDesc;
import hxd.Res;
import haxe.ds.HashMap;
import h2d.col.IBounds;
import hxd.Pixels;
import utils.Direction4;
import h2d.Tile;
import haxe.ds.Map;

using extenders.TileExtender;

typedef TileType = world.tilemapgen.Main.TileType;

class WorldTilemap {
    static private var json: JsonMap;

    static public function init (): Void {
        var parser = new json2object.JsonParser<JsonMap>();
        parser.fromJson(
            hxd.Res.parsed.tilemap.gen.tilemap_json.entry.getText(),
            hxd.Res.parsed.tilemap.gen.tilemap_json.name
        );
        if (parser.errors.length > 0)
            trace(json2object.ErrorUtils.convertErrorArray(parser.errors));
        json = parser.value;
    }

    static public inline function getGlobalTile (): Tile {
        return hxd.Res.parsed.tilemap.gen.tilemap_png.toTile();
    }

    static public function getTile (tile: TileDesc): Tile {
        var hash = Main.hashTile(tile);
        var x: Int = json[hash][0];
        var y: Int = json[hash][1];
        var tile = getGlobalTile();
        tile.setPosition(
            x * Main.TILE_PX_SIZE,
            y * Main.TILE_PX_SIZE
        );
        tile.setSize(
            Main.TILE_PX_SIZE,
            Main.TILE_PX_SIZE
        );
        return tile;
    }
}
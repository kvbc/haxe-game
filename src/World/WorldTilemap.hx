package world;

import hxd.Res;
import haxe.ds.HashMap;
import h2d.col.IBounds;
import hxd.Pixels;
import utils.Direction4;
import h2d.Tile;
import haxe.ds.Map;

using extenders.TileExtender;

enum TileType {
    GRASS;
    WATER;
    SAND;
}

class Tilemap {
    static public inline var TILE_PX_SIZE = 16;
    static public inline var TILE_WIDTH = 7;
    static public inline var TILE_HEIGHT = 3;

    private var tiles: Array<Array<h2d.Tile>>;

    public function new (tile: h2d.Tile) {
        Debug.assert(tile.width == TILE_WIDTH * TILE_PX_SIZE);
        Debug.assert(tile.height == TILE_HEIGHT * TILE_PX_SIZE);
        this.tiles = tile.grid(TILE_PX_SIZE);
    }

    public function getTile (connections: Direction4Bitmask): h2d.Tile {
        var c = connections;
        // 4
        if (c & [UP, LEFT, RIGHT, DOWN]) return tiles[6][1];
        // 3
        if (c & [UP,   LEFT,  RIGHT])    return tiles[3][0];
        if (c & [UP,   LEFT,  DOWN])     return tiles[4][0];
        if (c & [UP,   RIGHT, DOWN])     return tiles[6][0];
        if (c & [DOWN, LEFT,  RIGHT])    return tiles[3][2];
        // 2
        if (c & [UP,   LEFT])            return tiles[0][0];
        if (c & [UP,   RIGHT])           return tiles[2][0];
        if (c & [UP,   DOWN])            return tiles[5][0];
        if (c & [LEFT, RIGHT])           return tiles[3][1];
        if (c & [DOWN, LEFT])            return tiles[0][2];
        if (c & [DOWN, RIGHT])           return tiles[2][2];
        // 1
        if (c & [UP])                    return tiles[1][0];
        if (c & [LEFT])                  return tiles[0][1];
        if (c & [RIGHT])                 return tiles[2][1];
        if (c & [DOWN])                  return tiles[1][2];
        // 0
        if (c.isEmpty())                 return tiles[6][1];
        // ???
        throw "Invalid bitmask";
        return null;
    }
}

abstract HashedConnectionsMap(String) from String {}
typedef ConnectionsMap = Map<TileType, Direction4Bitmask>;
private function hashConnectionsMap (map: ConnectionsMap): HashedConnectionsMap {
    var hash = "";
    for (tileType => directions in map)
        hash += '$tileType$directions';
    return hash;
}

class WorldTilemap {
    static private var tilesets = new Map<TileType, {
        frontTilemap: Tilemap,
        backTilemaps: Map<TileType, Tilemap>
    }>();
    static private var tilePixelsCache = new Map<h2d.Tile, hxd.Pixels>();
    static private var tileCache = new Map<TileType, Map<HashedConnectionsMap, h2d.Tile>>();

    static public function init () {
    #if !parsing
        for (tileType in Type.allEnums(TileType)) {
            var frontTile: Tile = (switch (tileType) {
                case GRASS : Res.parsed.tilemap.front_pink;
                case SAND  : Res.parsed.tilemap.front_blue;
                case WATER : Res.parsed.tilemap.front_red;
            }).toTile();
            
            var backTilemaps = new Map<TileType, Tilemap>();
            for (backTileType in Type.allEnums(TileType)) {
                var tile: Tile = (switch ([tileType, backTileType]) {
                    case [GRASS, GRASS] : continue;
                    case [SAND,  SAND]  : continue;
                    case [WATER, WATER] : continue;
                    case [GRASS, WATER] : Res.parsed.tilemap.back_water_pink;
                    case [GRASS, SAND]  : Res.parsed.tilemap.back_sand_pink;
                    case [WATER, GRASS] : Res.parsed.tilemap.back_grass_red;
                    case [WATER, SAND]  : Res.parsed.tilemap.back_sand_red;
                    case [SAND,  GRASS] : Res.parsed.tilemap.back_grass_blue;
                    case [SAND,  WATER] : Res.parsed.tilemap.back_water_blue;             
                }).toTile();
                backTilemaps[backTileType] = new Tilemap(tile);
            }

            tileCache[tileType] = new Map<HashedConnectionsMap, h2d.Tile>();

            tilesets[tileType] = {
                frontTilemap: new Tilemap(frontTile),
                backTilemaps: backTilemaps
            }
        }
    #end
    }

    static private function getTilePixels (tile: h2d.Tile): hxd.Pixels {
        if (tilePixelsCache.exists(tile))
            return tilePixelsCache[tile].clone();
        var pixels = tile.getTexture().capturePixels(0, 0,
            IBounds.fromValues(tile.ix, tile.iy, tile.iwidth, tile.iheight)
        );
        tilePixelsCache[tile] = pixels.clone();
        return pixels.clone();
    }

    static public function getTile (backTile: TileType, frontConnections: ConnectionsMap): h2d.Tile {
        var frontConnectionsHash = hashConnectionsMap(frontConnections);
        var cachedTile = tileCache[backTile][frontConnectionsHash];
        if (cachedTile != null)
            return cachedTile;

        var pixels = getTilePixels(tilesets[backTile].frontTilemap.getTile(new Direction4Bitmask()));

        for (tileType => connections in frontConnections) {
            var backPixels = getTilePixels(tilesets[tileType].backTilemaps[backTile].getTile(connections));
            var frontPixels = getTilePixels(tilesets[tileType].frontTilemap.getTile(connections));
            for (neighbourPixels in [backPixels, frontPixels]) {
                for (x in 0 ... neighbourPixels.width)
                for (y in 0 ... neighbourPixels.height) {
                    var pixelF = neighbourPixels.getPixelF(x, y);
                    if (pixelF.a > 0.1) {
                        pixels.setPixelF(x, y, pixelF);
                    }
                }
            }
        }

        var tile = h2d.Tile.fromPixels(pixels);
        tileCache[backTile][frontConnectionsHash] = tile;
        return tile;
    }
}
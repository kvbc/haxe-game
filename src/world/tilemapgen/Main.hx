package world.tilemapgen;

import haxe.io.Bytes;
import haxe.Json;
import haxe.Http;
import hxd.File;
import world.WorldTilemap;
import hxd.Res;
import haxe.ds.HashMap;
import h2d.col.IBounds;
import hxd.Pixels;
import utils.Direction4;
import h2d.Tile;
import haxe.ds.Map;

using extenders.TileExtender;

class Tilemap {
    static public inline var TILE_WIDTH = 7;
    static public inline var TILE_HEIGHT = 3;

    private var tiles: Array<Array<h2d.Tile>>;

    public function new (tile: h2d.Tile) {
        Debug.assert(tile.width == TILE_WIDTH * Main.TILE_PX_SIZE);
        Debug.assert(tile.height == TILE_HEIGHT * Main.TILE_PX_SIZE);
        this.tiles = tile.grid(Main.TILE_PX_SIZE);
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

// enum TileType {
//     GRASS;
//     WATER;
//     SAND;
// }
enum TileType {
    WATER;
    SAND;
    GRASS;
}


typedef JsonMap = Map<String, Array<Int>>; // back tile + hashed neighbour map -> [x, y]

typedef TileDesc = {
    backTileType: TileType,
    neighbours: Map<Direction4, TileType>
}

class Main extends hxd.App {
    static public inline var TILE_PX_SIZE: Int = 16;
    static public inline var MIN_ALPHA: Float = 0.1;

    static private function main () {
        new Main();
    }

    static public function hashTile (tile: TileDesc): String {
        var hash = '${tile.backTileType}';
        for (dir in Direction4.getAll()) {
            hash += ' ';
            if (tile.neighbours.exists(dir))
                hash += '${tile.neighbours[dir]}';
            else
                hash += '-';
        }
        return hash;
    }
    
#if !tile_parsing
    override public function init () {
        hxd.Res.initEmbed();

        function getFrontTilemap (tileType: TileType): Tilemap {
            return new Tilemap((switch (tileType) {
                case GRASS : Res.parsed.tilemap.front_pink;
                case SAND  : Res.parsed.tilemap.front_blue;
                case WATER : Res.parsed.tilemap.front_red;
            }).toTile());
        }

        var tiles = new Array<{
            desc: TileDesc,
            pixels: Pixels
        }>();
        
        function generatePixels (
            backTileType: TileType,
            dirTileMap: Null<Map<Direction4, TileType>> = null    
        ): Pixels {
            if (dirTileMap == null)
                dirTileMap = new Map();

            var newPixels = getFrontTilemap(backTileType).getTile(new Direction4Bitmask()).getPixels(RELATIVE);

            for (tileType in Type.allEnums(TileType))
            if (tileType != backTileType) {
                var frontConnections = new Direction4Bitmask();
                for (dir => type in dirTileMap)
                    if (type == tileType)
                        frontConnections |= dir;
                if (frontConnections.isEmpty())
                    continue;

                var edgeTilemap = new Tilemap((switch ([tileType, backTileType]) {
                    case [GRASS, GRASS] : throw "Error";
                    case [SAND,  SAND ] : throw "Error";
                    case [WATER, WATER] : throw "Error";
                    case [GRASS, WATER] : Res.parsed.tilemap.back_water_pink;
                    case [GRASS, SAND ] : Res.parsed.tilemap.back_sand_pink;
                    case [WATER, GRASS] : Res.parsed.tilemap.back_grass_red;
                    case [WATER, SAND ] : Res.parsed.tilemap.back_sand_red;
                    case [SAND,  GRASS] : Res.parsed.tilemap.back_grass_blue;
                    case [SAND,  WATER] : Res.parsed.tilemap.back_water_blue;             
                }).toTile());

                var edgePixels = edgeTilemap.getTile(frontConnections).getPixels(RELATIVE);
                var frontPixels = getFrontTilemap(tileType).getTile(frontConnections).getPixels(RELATIVE);
                for (pixels in [edgePixels, frontPixels])
                for (x in 0 ... pixels.width)
                for (y in 0 ... pixels.height) {
                    var pixelF = pixels.getPixelF(x, y);
                    if (pixelF.a > MIN_ALPHA)
                        newPixels.setPixelF(x, y, pixelF);
                }
            }

            return newPixels;
        }

        function generateTile (
            backTileType: TileType,
            dirTileMap: Null<Map<Direction4, TileType>> = null,
            dirIdx: Int = 0
        ): Void {
            if (dirIdx >= Direction4.getAll().length)
                return;

            if (dirTileMap == null)
                dirTileMap = new Map();

            tiles.push({
                desc: {
                    backTileType: backTileType,
                    neighbours: []
                },
                pixels: generatePixels(backTileType)
            });
            generateTile(backTileType, dirTileMap, dirIdx + 1);
            
            for (frontTileType in Type.allEnums(TileType))
            if (frontTileType != backTileType) {
                var newDirTileMap = dirTileMap.copy();
                {
                    var dir = Direction4.getAll()[dirIdx];
                    newDirTileMap[dir] = frontTileType;
                }
                tiles.push({
                    desc: {
                        backTileType: backTileType,
                        neighbours: newDirTileMap.copy()
                    },
                    pixels: generatePixels(backTileType, newDirTileMap),
                });
                generateTile(backTileType, newDirTileMap, dirIdx + 1);
            }
        }

        for (backTileType in Type.allEnums(TileType)) {
            generateTile(backTileType);
        }

        var tileWidth = Std.int(
            Math.pow(2,
                Math.ceil(
                    Math.log(Math.sqrt(tiles.length)) / Math.log(2)
                )
            )
        );
        var tileHeight = tileWidth;
        var pxWidth = tileWidth * TILE_PX_SIZE;
        var pxHeight = tileHeight * TILE_PX_SIZE;
        var pixels = Pixels.alloc(pxWidth, pxHeight, ARGB);

        trace('tiles : ${tiles.length}');
        trace('size  : ${tileWidth}x${tileHeight} tiles (${pxWidth}x${pxHeight} px)');

        var json = new JsonMap();

        var i = 0;
        for (tileY in 0 ... tileHeight) {
            var br = false;
            for (tileX in 0 ... tileWidth) {
                if (i >= tiles.length) {
                    br = true;
                    break;
                }

                var tile = tiles[i];

                for (ix in 0 ... TILE_PX_SIZE)
                for (iy in 0 ... TILE_PX_SIZE) {
                    var x = tileX * TILE_PX_SIZE + ix;
                    var y = tileY * TILE_PX_SIZE + iy;
                    pixels.setPixel(
                        x, y,
                        tile.pixels.getPixel(ix, iy)
                    );
                }

                json[hashTile(tile.desc)] = [tileX, tileY];

                i++;
            }
            if (br)
                break;
        }

        File.saveBytes(
            "res/parsed/tilemap/gen/tilemap.png",
            pixels.toPNG()
        );

        File.saveBytes(
            "res/parsed/tilemap/gen/tilemap.json",
            Bytes.ofString(Json.stringify(json, '\t'))
        );

        hxd.System.exit();
    }
#end // if !tile_parsing
}
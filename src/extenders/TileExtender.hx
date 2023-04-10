package extenders;

import h2d.col.IBounds;
import hxd.Pixels;

enum GetPixelsMode {
    ABSOLUTE;
    RELATIVE;
}

class TileExtender {
    static private var didSplitColorWarn = false;

    static public function scale (tile: h2d.Tile, percentage: Float): h2d.Tile {
        tile.scaleToSize(
            tile.width * percentage,
            tile.height * percentage
        );
        return tile;
    }

    static public function centerSelf (tile: h2d.Tile): h2d.Tile {
        tile.dx = -tile.width / 2;
        tile.dy = -tile.height / 2;
        return tile;
    }

    static public function getPixels (tile: h2d.Tile, mode: GetPixelsMode): hxd.Pixels {
        static var absoluteCache = new Map<h2d.Tile, hxd.Pixels>();
        static var relativeCache = new Map<h2d.Tile, Map<String, hxd.Pixels>>();

        var boundsStr: String = '${tile.ix} ${tile.iy} ${tile.iwidth} ${tile.iheight}';

        switch (mode) {
            case ABSOLUTE:
                if (absoluteCache.exists(tile))
                    return absoluteCache[tile].clone();
            case RELATIVE:
                if (relativeCache.exists(tile)) {
                    if (relativeCache[tile].exists(boundsStr))
                        return relativeCache[tile][boundsStr].clone();
                } else {
                    relativeCache[tile] = new Map();
                }
        }

        var pixels: Pixels = switch (mode) {
            case ABSOLUTE:
                tile.getTexture().capturePixels();
            case RELATIVE:
                tile.getTexture().capturePixels(0, 0,
                    IBounds.fromValues(tile.ix, tile.iy, tile.iwidth, tile.iheight)
                );
        }

        switch (mode) {
            case ABSOLUTE:
                absoluteCache[tile] = pixels.clone();
            case RELATIVE:
                relativeCache[tile][boundsStr] = pixels.clone();
        }

        return pixels.clone();
    }
}
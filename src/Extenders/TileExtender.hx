package extenders;

import utils.Measure;
import hxd.Pixels;
import math.IntRect;
import h2d.col.IBounds;
import haxe.PosInfos;
import utils.Color;

// enum GetPixelsMode {
//     ABSOLUTE;
//     RELATIVE;
// }

class TileExtender {
    static private var didSplitColorWarn = false;
    // static private var pixelsCache = new Map<h2d.Tile, Map<GetPixelsMode, hxd.Pixels>>();

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

    // static public function getPixels (tile: h2d.Tile, mode: GetPixelsMode): hxd.Pixels {
    //     if (pixelsCache.exists(tile)) {
    //         if (pixelsCache[tile].exists(mode))
    //             return pixelsCache[tile][mode].clone();
    //     } else {
    //         pixelsCache[tile] = new Map();
    //     }

    //     var pixels: Pixels = switch (mode) {
    //         case ABSOLUTE:
    //             tile.getTexture().capturePixels();
    //         case RELATIVE:
    //             tile.getTexture().capturePixels(0, 0,
    //                 IBounds.fromValues(tile.ix, tile.iy, tile.iwidth, tile.iheight)
    //             );
    //     }

    //     return pixelsCache[tile][mode] = pixels.clone();
    // }
}
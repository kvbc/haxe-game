package tileparser;

import haxe.PosInfos;
import utils.Color;
import utils.Measure;
import math.IntRect;
import sys.FileSystem;

enum abstract SplitColor(Color) from Color to Color {
    static public var RED       (default, never) = Color.fromFloats(1, 0, 0); // 0xFF0000;
    static public var GREEN     (default, never) = Color.fromFloats(0, 1, 0); // 0x00FF00;
    static public var BLUE      (default, never) = Color.fromFloats(0, 0, 1); // 0x0000FF;
    static public var YELLOW    (default, never) = Color.fromFloats(1, 1, 0); // 0xFFFF00;
    static public var PINK      (default, never) = Color.fromFloats(1, 0, 1); // 0xFF00FF;
    static public var LIGHTBLUE (default, never) = Color.fromFloats(0, 1, 1); // 0x00FFFF;

    static public function getAll (): Array<SplitColor> {
        return [RED, GREEN, BLUE, YELLOW, PINK, LIGHTBLUE];
    }

    public function toString (): String {
        return switch (this: SplitColor) {
            case RED:       "red";
            case GREEN:     "green";
            case BLUE:      "blue";
            case YELLOW:    "yellow";
            case PINK:      "pink";
            case LIGHTBLUE: "lightblue";
        }
    }
}

// typedef ColorSplitRects = Map<SplitColor, IntRect>;
// typedef ColorSplitSubtiles = Map<SplitColor, h2d.Tile>;

class Main extends hxd.App {
    private static var EXCLUDE_COLOR = Color.fromFloats(1,1,1); // 0xFFFFFF
    private static var EXCLUDE_COLOR_THRESHOLD: Float = 0.1;
    private static inline var SPLIT_COLOR_THRESHOLD: Float = 0.2;
    private static inline var SPLIT_COLOR_WARN_THRESHOLD: Float = 0.3;
    // private static inline var MIN_ALPHA: Float = 0.9;

    static private function main () {
        new Main();
    }

    static private function parseTile (tile: h2d.Tile, relPath: String, ?pos: PosInfos): Void {
        function isSplitColor (color: Color, splitColor: SplitColor, ?pos: PosInfos): Bool {
            var isSimilar = color.isSimilar(splitColor, SPLIT_COLOR_THRESHOLD);
    
            static var warned = false;
            if (!warned)
            if (!isSimilar)
            if (color.isSimilar(splitColor, SPLIT_COLOR_WARN_THRESHOLD)) {
                Logger.log("Some pixel colors are very close to area colors", WARN, pos);
                warned = true;
            }
    
            return isSimilar;
        }

        var pixels = tile.getTexture().capturePixels();
        var colorRects = new Map<SplitColor, IntRect>();

        for (x in 0 ... pixels.width)
        for (y in 0 ... pixels.height) {
            var pixelColor = Color.fromInt(pixels.getPixel(x, y));
            for (splitColor in SplitColor.getAll()) {
                if (isSplitColor(pixelColor, splitColor)) {
                    var pixelRect = IntRect.fromDimensions(x, y, 1, 1);
                    if (colorRects.exists(splitColor))
                        colorRects[splitColor].expandToFit(pixelRect)
                    else
                        colorRects[splitColor] = pixelRect;
                    break;
                }
            }
        }

        var newPixels = pixels.clone();

        for (color => rect in colorRects) {
            var newRect: Null<IntRect> = null;

            for (x in rect.left ... rect.right + 1)
            for (y in rect.top  ... rect.bottom + 1) {
                var pixel = pixels.getPixel(x, y);
                var pixelColor = Color.fromInt(pixel);

                // if (pixelColor.af < MIN_ALPHA)
                //     continue;

                var skip = false;
                for (splitColor in SplitColor.getAll()) {
                    if (isSplitColor(pixelColor, splitColor)) {
                        if (splitColor == color) {
                            newPixels.setPixel(x, y, 0); // transparent
                        }
                        skip = true;
                        break;
                    }
                }
                if (skip)
                    continue;

                if (pixelColor.isSimilar(EXCLUDE_COLOR, EXCLUDE_COLOR_THRESHOLD)) {
                    newPixels.setPixel(x, y, 0); // transparent
                }

                var pixelRect = IntRect.fromDimensions(x, y, 1, 1);
                if (newRect == null)
                    newRect = pixelRect;
                else
                    newRect.expandToFit(pixelRect);
            }

            Debug.assert(newRect != null);
            colorRects[color] = newRect;
        }

        for (color => rect in colorRects) {
            hxd.File.saveBytes(
                absResParsedPath(
                    relPath.substring(0, relPath.lastIndexOf("."))
                    + '_'
                    + color.toString()
                    + '.png'
                ),
                newPixels.sub(rect.x, rect.y, rect.width, rect.height).toPNG()
            );
        }
    }

    static private function absResParsedPath (?relPath: String = ""): String {
        return FileSystem.absolutePath(resParsedPath(relPath));
    }

    static private function absResParsePath (?relPath: String = ""): String {
        return FileSystem.absolutePath(resParsePath(relPath));
    }

    static private function resPath       (?relPath: String = ""): String { return joinPath("res", relPath); }
    static private function parsePath     (?relPath: String = ""): String { return joinPath("parse", relPath); }
    static private function parsedPath    (?relPath: String = ""): String { return joinPath("parsed", relPath); }
    static private function resParsePath  (?relPath: String = ""): String { return resPath(parsePath(relPath)); }
    static private function resParsedPath (?relPath: String = ""): String { return resPath(parsedPath(relPath)); }

    static private function joinPath (p1: String, p2: String): String {
        if (p1 == "")
            return p2;
        if (p2 == "")
            return p1;
        return '$p1/$p2';
    }

    static private function parseDirectory (relPath: String = "", indent: Int = 0): Void {
        if (!FileSystem.exists(absResParsedPath(relPath)))
            FileSystem.createDirectory(absResParsedPath(relPath));

        var fileNames = FileSystem.readDirectory(absResParsePath(relPath));
        for (fileName in fileNames) {
            var filePath = joinPath(relPath, fileName);
            if (FileSystem.isDirectory(absResParsePath(filePath))) {
                parseDirectory(filePath, indent + 1);
            } else {
                var measure = new Measure();
                var tile = hxd.Res.loader.load(parsePath(filePath)).toTile();
                parseTile(tile, filePath);
                measure.endLog('parsed ${filePath}');
            }
        }
    }

    override private function init () {
        hxd.Res.initEmbed();

        trace("parsing!");

        parseDirectory();

        hxd.System.exit();
    }
}
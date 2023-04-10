package;

import world.WorldDebugGrid;
import haxe.Json;
import event.EventDispatcher;
import hxd.Window;
import h2d.Console.ConsoleArgDesc;
import utils.Measure;
import world.World;
import haxe.PosInfos;
import hxd.Key;
import Player;

class Game extends hxd.App {
    static public function main () {
        Game.instance = new Game();
    }

    static public var instance(default, null): Null<Game> = null;

    var uiScene: h2d.Scene;
    var debugScene: h2d.Scene;
    var debugText: h2d.Text;
    var console: h2d.Console;

    var showDebugInfo: Bool = false;
    var logToConsole: Bool = true;

    static public var lastUpdateTime(default, null): Float = 0.0;

    /*
     *
     * App
     * 
     */

    override function init (): Void {
        hxd.Res.initEmbed();

        // hxd.Window.getInstance().onClose = () -> {
        //     var stack = Profiler.getCallStack();
        //     var json = Json.stringify({ stack:stack });
        //     hxd.File.saveBytes("profiler.json", haxe.io.Bytes.ofString(json));
        //     return true; // ???
        // }

        {
            // h2d.Console.HIDE_LOG_TIMEOUT = 10;
            uiScene = new h2d.Scene();
            {
                console = new h2d.Console(hxd.Res.fonts.console.toFont());

                function addCommand (name: String, ?help: String, args: Array<ConsoleArgDesc>, callb: Dynamic): Void {
                    console.addCommand(name, help, args, callb);

                    var alias = name.charAt(0);
                    for (i in 0 ... name.length) {
                        var char = name.charAt(i);
                        if (char == char.toUpperCase())
                            alias += char.toLowerCase();
                    }
                    console.addAlias(alias, name);
                }

                addCommand("toggleShowDebugGrid", "TODO", [], () -> WorldDebugGrid.visible = !WorldDebugGrid.visible);
                addCommand("toggleShowDebugInfo", "TODO", [], () -> showDebugInfo = !showDebugInfo);
                addCommand("toggleConsoleLog", "TODO", [], () -> logToConsole = !logToConsole);
                addCommand("toggleVSYNC", "TODO", [], () -> {
                    var w = hxd.Window.getInstance();
                    w.vsync = !w.vsync;
                });

                uiScene.addEventListener((event: hxd.Event) -> {
                    if (event.kind == EKeyDown)
                    if ([Key.QWERTY_TILDE, Key.QWERTY_SLASH, Key.F1].contains(event.keyCode))
                    if (!console.isActive())
                        console.show();
                });
            }
            uiScene.addChild(console);
        }
        setScene(uiScene); // FIXME

        debugScene = new h2d.Scene();
        debugText = new h2d.Text(hxd.res.DefaultFont.get());
        debugScene.addChild(debugText);

        World.init("DEV");
    }

    override function render (engine) {
        World.scene.render(engine);
        if (showDebugInfo)
            debugScene.render(engine);
        uiScene.render(engine);
    }

    override function update (delta: Float): Void {
        var measure = new Measure();

        World.update(delta);

        if (showDebugInfo) {
            debugText.text = '${World.toString()}';
        }

        // Game.lastUpdateTime = measure.end();
        Game.lastUpdateTime = measure.end();
    }

    /*
     *
     * 
     * 
     */

    static public function log (message: String, color: Int): Void {
        if (Game.instance != null)
        if (Game.instance.logToConsole)
            Game.instance.console.log(message, color);
    }
}
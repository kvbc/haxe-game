package utils;

import haxe.PosInfos;
import Logger.LogLevel;

class Measure {
    private var startTimestamp: Float;

    public function new () {
        this.startTimestamp = haxe.Timer.stamp();
    }

    public function end (): Float {
        var endTimestamp = haxe.Timer.stamp();
        var elapsedTime = endTimestamp - this.startTimestamp;
        return elapsedTime;
    }

    public function endLog (?message: String = "-------------------------", ?level: LogLevel = DEBUG, ?showPos: Bool = false, ?pos: PosInfos): Void {
        var elapsedTime = end();
        Logger.log(message, level, elapsedTime, showPos, pos);
    }
}
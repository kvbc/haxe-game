package;

import haxe.PosInfos;

using extenders.FloatExtender;
using extenders.PosInfosExtender;
using extenders.StringExtender;

enum LogLevel {
    INFO;
    DEBUG;
    WARN;
    ERROR;
}

class Logger {
    public static inline var MIN_MESSAGE_PAD_LENGTH = 30;

    public static function log (?message: String = "", ?level: LogLevel = INFO, ?measureTime: Null<Float> = null, ?showPos: Bool = false, ?pos: PosInfos) {
        var color = switch (level) {
            case INFO : 0xFFFFFF;
            case DEBUG: 0x00FFFF;
            case WARN : 0xFFFF00;
            case ERROR: 0xFF0000;
        }

        var prefix = '$level'.padRight(5, ' ');

        function timeToString (?seconds: Null<Float>): String {
            var string = "";
            if (seconds != null) {
                if (seconds > 1.0)
                    string = Std.string(seconds.roundPrecision(1)) + "s";
                else
                    string = Std.string(cast(seconds * 1000, Int)) + "ms";
            }
            return string.padRight(5, '.');
        }

        var padding = '.'.repeat(3);

        var nowTimestamp = haxe.Timer.stamp();
        var updateTime = nowTimestamp - hxd.Timer.lastTimeStamp;
        var updateTimeString = timeToString(updateTime);

        var measureString = timeToString(measureTime);
        var measurePercentString = "";
        if (measureTime != null) {
            var measurePercent = measureTime / updateTime;
            measurePercentString = '${cast(measurePercent * 100, Int)}';
        }
        measurePercentString = measurePercentString.padRight(3, ".");
        measurePercentString += (measureTime != null) ? '%' : '.';

        var posString = pos.toString();

        message = message.padLeft(MIN_MESSAGE_PAD_LENGTH, '.');
        message = '[$prefix] $padding ($measureString / $updateTimeString - $measurePercentString) $padding $message (at $posString)';

        trace(message);
        Game.log(message, color);
    }
}
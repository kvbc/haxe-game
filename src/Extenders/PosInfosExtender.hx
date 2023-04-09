package extenders;

import haxe.PosInfos;

class PosInfosExtender {
    static public function toString (pos: PosInfos): String {
        return '${pos.className}:${pos.lineNumber}';
    }
}
package extenders;

class StringExtender {
    static public function padRight (string: String, minLength: Int, padString: String = ' '): String {
        Debug.assert(minLength > 0);
        if (string.length >= minLength)
            return string;
        for (i in 0 ... minLength - string.length) {
            string = padString + string;
        }
        return string;
    }

    static public function padLeft (string: String, minLength: Int, padString: String = ' '): String {
        Debug.assert(minLength > 0);
        if (string.length >= minLength)
            return string;
        for (i in 0 ... minLength - string.length) {
            string += padString;
        }
        return string;
    }

    static public function repeat (string: String, nTimes: Int): String {
        var ret = "";
        for (i in 0 ... nTimes)
            ret += string;
        return ret;
    }
}
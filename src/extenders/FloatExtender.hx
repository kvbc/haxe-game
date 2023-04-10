package extenders;

class FloatExtender {
    static public function roundPrecision (number: Float, ?precision: Int = 2): Float {
        var p10: Float = Math.pow(10, precision);
        return Math.round(number * p10) / p10;
    }
}
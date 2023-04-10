package;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.ExprOf;
import haxe.PosInfos;
import haxe.Exception;

using extenders.PosInfosExtender;

class Debug {
#if macro
    static private function wrapExpr (exprDef: ExprDef): Expr {
        return {
            expr: exprDef,
            pos: Context.currentPos()
        }
    }
#end

    static public macro function assert (condition: Expr, message: String = "error"): Expr {
    #if release
        return macro null;
    #else
        return wrapExpr(EIf(
            wrapExpr(EUnop(OpNot, false, condition)),
            wrapExpr(EThrow(
                wrapExpr(EConst(CString(message)))
            )),
            null
        ));
    #end
    }

    static public inline function assertRange (value: Float, min: Float, max: Float, ?pos: PosInfos): Void {
    #if !release
        if (!(value >= min && (value <= max))) {
            throw '$value not in range ($min, $max)';
        }
        // assert((value >= min) && (value <= max), '$value not in range ($min, $max)', pos);
    #end
    }
}
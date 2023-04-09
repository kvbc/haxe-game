package macros;

import event.EventDispatcher;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

class ForwardOpsMacro {
    static private function assertAbstract (type: Type): Void {
        if (!type.match(TAbstract(_,_)))
            Context.error('type $type expected to be an Abstract', Context.currentPos());
    }

    static private function getAbstractRef (type: Type): Ref<AbstractType> {
        assertAbstract(type);
        return switch (type) {
            case TAbstract(ref, _):
                ref;
            case _: throw "Error";
        }
    }

    static private function wrapExpr (exprDef: ExprDef): Expr {
        return {
            expr: exprDef,
            pos: Context.currentPos()
        }
    }

    static private function hasMeta (metadata: Metadata, name: String): Bool {
        for (meta in metadata)
            if (meta.name == name)
                return true;
        return false;
    }

    macro static public function build (localTypePath: String, baseTypePath: String): Array<Field> {
        var localType: Type = Context.getType(localTypePath);
        var localComplexType: ComplexType = {
            assertAbstract(localType);
            Context.toComplexType(localType);
        }
        var localAbstractRef: Ref<AbstractType> = getAbstractRef(localType);
        var localID = localAbstractRef.toString();

        var baseType: Type = Context.getType(baseTypePath);
        var baseComplexType: ComplexType = {
            assertAbstract(baseType);
            Context.toComplexType(baseType);
        }
        var baseAbstractRef: Ref<AbstractType> = getAbstractRef(baseType);
        var baseID = baseAbstractRef.toString();

        // 
        trace('--- $localTypePath extends $baseTypePath ---');
        // 

        var fields = Context.getBuildFields();
        
        var forwardFromBaseMetaName = 'opForwardedFrom_$baseID';

        for (baseField in baseAbstractRef.get().impl.get().statics.get()) {
            if (!baseField.meta.has(":op"))
                continue;

            var skip = false;
            for (localField in fields) {
                if (localField.name == baseField.name) {
                    skip = true;
                    // if (hasMeta(localField.meta, forwardFromBaseMetaName)) {
                    //     skip = true;
                    // }
                    // } else {
                    //     Context.error('local class "${localTypePath}": field "${localField.name}" has the same name as base field in base class "${baseTypePath}"', localField.pos);
                    // }
                    break;
                }
            }
            if (skip)
                continue;

            //
            trace(ExprTools.toString(baseField.meta.extract(':op')[0].params[0]));
            // 

            var baseParams;
            var baseRet;
            {
                var type: Type = baseField.type;
                // Extract the actual type if the type is TLazy
                type = switch(type) {
                    case TLazy(_ => _() => actualType):
                        actualType;
                    case _: type;
                }

                switch (type) {
                    case TFun(args, ret):
                        baseParams = args;
                        baseRet = ret;
                    case _: throw "Error"; // static fields with @:op should always be functions
                }
            }
            
            var newExpr: Expr = wrapExpr({
                var castedThis: Expr = wrapExpr(ECast(
                    wrapExpr(EConst(CIdent("this"))),
                    baseComplexType
                ));

                switch (baseField.meta.extract(':op')[0].params[0].expr) {
                    case EBinop(op, _, _):
                        EBinop(op, castedThis, wrapExpr(ECast(
                            wrapExpr(EConst(CIdent(baseParams[1].name))),
                            Context.toComplexType(baseParams[1].t)
                        )));
                    case EUnop(op, postFix, _):
                        EUnop(op, postFix, castedThis);
                    case _: throw "Error";
                }
            });

            var newFunc: Function = {
                args: (baseParams.length == 1) ? [] : [{
                    name: baseParams[1].name,
                    opt: baseParams[1].opt,
                    type: (getAbstractRef(baseParams[1].t).toString() == baseAbstractRef.toString())
                            ? localComplexType
                            : Context.toComplexType(baseParams[1].t)
                    // value?
                    // meta?
                }],
                ret: (getAbstractRef(baseRet).toString() == baseAbstractRef.toString())
                        ? localComplexType
                        : Context.toComplexType(baseRet)
                ,
                expr: macro return $newExpr
                // params?
            }

            // 
            trace(ExprTools.toString(newFunc.expr));
            // 

            var newMeta = baseField.meta.get(); // copy
            newMeta.push({
                name: forwardFromBaseMetaName,
                pos: baseField.pos,
                params: []
            });

            fields.push({
                name: baseField.name,
                doc: baseField.doc,
                access: [baseField.isPublic ? APublic : APrivate], // inherit access modifier
                kind: FFun(newFunc),
                pos: baseField.pos,
                meta: newMeta
            });
        }

        // 
        trace("---------- END ----------");
        // 

        return fields;
    }
}
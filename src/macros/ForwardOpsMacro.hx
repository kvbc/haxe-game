package macros;

import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using extenders.StringExtender;

class ForwardOpsMacro {
    private static var calls: Int = 0;
    private static var callIndent: Int = 0;

#if macro
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
#end // if macro

    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely
    // filler space so the line number in trace() is 3 digits and it all aligns nicely

    macro static public function build (): Array<Field> {
        calls++;

        //
        var startCallIndent = callIndent;
        function padding (): String {
            return '|   '.repeat(callIndent);
        }
        //

        var localClassTypeRef: Ref<ClassType> = Context.getLocalClass();
        var localClassType: ClassType = localClassTypeRef.get();
        var localAbstractRef: Ref<AbstractType> = switch (localClassType.kind) {
            case KAbstractImpl(abRef):
                abRef;
            case _:
                Context.error('type "$localClassTypeRef" must be an Abstract', localClassType.pos);
        }
        var localAbstract: AbstractType = localAbstractRef.get();
        // var localComplexType: ComplexType = Context.toComplexType(localAbstract.type);
        var localComplexType: ComplexType = {
            var params: Array<Type> = [
                for (param in localAbstract.params)
                    param.t
            ];
            var type = TAbstract(localAbstractRef, params);
            Context.toComplexType(type);
        }
        var localID = localAbstractRef.toString();

        var fields = Context.getBuildFields();

        var parentAbstract: AbstractType = localAbstract;
        while (true) {
            var baseType: Type = Context.follow(parentAbstract.type);
            var baseAbstractRef: Ref<AbstractType> = switch (baseType) {
                case TAbstract(abRef, _):
                    abRef;
                case _:
                    if (parentAbstract == localAbstract) {
                        Context.error('underlying type "${TypeTools.toString(baseType)}" must be an Abstract', localClassType.pos);
                    } else {
                        break;
                    }
            }
            var baseAbstract: AbstractType = baseAbstractRef.get();
            var baseID = baseAbstractRef.toString();
            var baseComplexType: ComplexType = Context.toComplexType(baseType);

            parentAbstract = baseAbstract; // for the next iteration

            //
            trace(padding() + 'abstract $localAbstractRef ($baseAbstractRef)');
            callIndent++;
            // 

            if (baseAbstract.impl == null) // for example, if underlying type is Int
                break;

            var forwardFromBaseMetaName = 'opForwardedFrom_$baseID';

            for (baseField in baseAbstract.impl.get().statics.get()) {
                if (!baseField.meta.has(":op"))
                    continue;

                var skip = false;
                for (localField in fields) {
                    if (localField.name == baseField.name) {
                        skip = true;
                        if (hasMeta(localField.meta, forwardFromBaseMetaName)) {
                            skip = true;
                        } else {
                            Context.error('local class "$localID": field "${localField.name}" has the same name as base field in base class "${baseID}"', localField.pos);
                        }
                        break;
                    }
                }
                if (skip)
                    continue;

                //
                trace(padding() + ExprTools.toString(baseField.meta.extract(':op')[0].params[0]));
                callIndent++;
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

                // trace(TypeTools.toString(baseRet) + " VS " + baseID + " == " + (TypeTools.toString(baseRet) == baseID));
                // trace(localID + " & " + baseID);

                var newFunc: Function = {
                    args: (baseParams.length == 1) ? [] : [{
                        name: baseParams[1].name,
                        opt: baseParams[1].opt,
                        // type: (getAbstractRef(baseParams[1].t).toString() == baseAbstractRef.toString())
                        type: (TypeTools.toString(baseParams[1].t) == baseID)
                                ? localComplexType
                                : Context.toComplexType(baseParams[1].t)
                        // value?
                        // meta?
                    }],
                    // ret: (getAbstractRef(baseRet).toString() == baseAbstractRef.toString())
                    ret: (TypeTools.toString(baseRet) == baseID)
                            ? localComplexType
                            : Context.toComplexType(baseRet)
                    ,
                    expr: macro return $newExpr
                    // params?
                }

                // 
                {
                    function complexTypeToString (complexType: ComplexType): String {
                        return TypeTools.toString(Context.resolveType(complexType, Context.currentPos()));
                    }
                    var argsStr: String = [
                        for (arg in newFunc.args)
                            '${arg.name}: ${complexTypeToString(arg.type)}'
                    ].join(', ');
                    var retStr: String = complexTypeToString(newFunc.ret);
                    trace(padding() + 'function ${baseField.name} ($argsStr): $retStr');
                    callIndent++; 
                    trace(padding() + ExprTools.toString(newFunc.expr));
                    callIndent--; 
                }
                callIndent--;
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

            callIndent--;
        }

        
        // 
        callIndent = startCallIndent;
        // 

        calls--;

        return fields;
    }
}
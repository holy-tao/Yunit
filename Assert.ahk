#Requires AutoHotkey v2.0

#Include Extensions.ahk

/**
 * Custom assertions for Yunit
 */
class Assert {

    /**
     * Assert that `callable` throws an object of type `errType`. This does not have to be an
     * Error, but it probably should
     * 
     * @param {Func () => Any} callable callable object that you expect to throw an error 
     * @param {Class} errType the type of the object you expect to be thrown. Probably something
     *          extending error 
     */
    static Throws(callable, errType){
        try{
            callable.Call()

        }
        catch Any as thrown{
            if(thrown is errType){
                return
            }

            throw TypeError(Format("Expected a(n) {1} but got a(n) {2}", errType.Prototype.__Class, Type(thrown)), -1)
        }

        throw Error(Format("Expeted {1} to throw a(n) {2}, but nothing was thrown", 
            (callable.HasProp("Name") && callable.Name != "") ? callable.Name : "Anonymous " . Type(callable),
            errType.Prototype.__Class
        ), -1)
    }

    /**
     * Assert that `obj` has a property named `propName` of type `propType`
     * @param {Object} obj 
     * @param {String} propName 
     * @param {Class} propType
     */
    static HasProp(obj, propName, propType){
        if(!obj.HasProp(propName)){
            throw Error(Format("Object of type '{1}' has no property named '{2}", Type(obj), propName))
        }

        if(!((val := obj.%propName%) is propType)){
            throw TypeError(Format("{1}.{2} is a(n) {3}, expected a(n) {4}", Type(obj), propName, Type(val), propType.Prototype.__Class))
        }
    }

    static Equals(left, right){
        if(left != right){
            throw Error(Format("{1} =/= {2}", String(left), String(right)), -1)
        }
    }

    static NotEquals(left, right){
        if(left != right){
            throw Error(Format("{1} == {2}", String(left), String(right)), -1)
        }
    }

    static BuffersEqual(left, right){
        if(left.size != right.size){
            throw Error(Format("Buffers {1} and {2} are not equal; sizes differ", String(left), String(right)), -1)
        }

        matchingBytes := DllCall("kernel32\RtlCompareMemory", "ptr", left.ptr, "ptr", right.ptr, "int", left.size)
        if(matchingBytes != left.size){
            throw Error(Format("{1} and {2} differ at offset {3}", String(left), String(right), matchingBytes), -1)
        }
    }
    
    static MapsEqual(left, right){
        for(key, val in left){
            if(!right.has(key) || (left[key] != right[key])){
                throw Error(Format("Maps {1} and {2} are not equal", String(left), String(right)))
            }
        }
    }

    static ArraysEqual(left, right){
        if(left.length != right.length){
            throw Error(Format("Arrays {1} and {2} are not equal", String(left), String(right)))
        }

        Loop(left.length){
            if(left[A_Index] != right[A_Index]){
                throw Error(Format("Arrays {1} and {2} differ at index {3}", String(left), String(right), A_Index))
            }
        }
    }

    static IsType(val, expected){
        if(!(val is expected)){
            throw TypeError(Format("Expected a(n) {1} but got a(n) {2}", expected.Prototype.__Class, Type(val)), , String(val))
        }
    }
}
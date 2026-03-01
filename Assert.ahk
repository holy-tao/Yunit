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
     * @param {Object} obj the object to check
     * @param {String} propName name of the property it is expected to have
     * @param {Class} propType type of the property's value ("Any" to allow anything)
     */
    static HasProp(obj, propName, propType := Any){
        if(!obj.HasProp(propName)){
            throw Error(Format("Object of type '{1}' has no property named '{2}", Type(obj), propName))
        }

        if(!((val := obj.%propName%) is propType)){
            throw TypeError(Format("{1}.{2} is a(n) {3}, expected a(n) {4}", Type(obj), propName, Type(val), propType.Prototype.__Class))
        }
    }

    /**
     * Assert that `left` is equal to `right` according to the != operator
     * @param {Any} left the first object to compare
     * @param {Any} right the second object to compare
     */
    static Equals(left, right){
        if(left != right){
            throw Error(Format("{1} =/= {2}", String(left), String(right)), -1)
        }
    }

    /**
     * Assert that `left` is not equal to `right` according to the == operator
     * @param {Any} left 
     * @param {Any} right 
     */
    static NotEquals(left, right){
        if(left == right){
            throw Error(Format("{1} == {2}", String(left), String(right)), -1)
        }
    }

    /**
     * Assert that the contents of two buffers are identical
     * @param {Buffer} left 
     * @param {Buffer} right 
     */
    static BuffersEqual(left, right){
        if(left.size != right.size){
            throw Error(Format("Expected {1} but got {2}; sizes differ", String(left), String(right)), -1)
        }

        matchingBytes := A_PtrSize == 8 ? 
            DllCall("ntdll\RtlCompareMemory", "ptr", left.ptr, "ptr", right.ptr, "int", left.size) :
            DllCall("msvcrt\memcmp", "ptr", left.ptr, "ptr", right.ptr, "uint", left.size, "cdecl int")
        if(matchingBytes != A_PtrSize == 8 ? left.size : 0){
            throw Error(Format("Expected {1} but got {2}; difference at offset {3}", String(left), String(right), matchingBytes), -1)
        }
    }
    
    /**
     * Assert that two maps are structurally equivalent (that is, they contain the same keys and for every key,
     * the values are either collections of the same type or objects where left != right returns false)
     * @param {Map<Any, Any>} left 
     * @param {Map<Any, Any>} right 
     */
    static MapsEqual(left, right){
        for(key, val in left){
            if(!right.has(key)){
                throw Error(Format("Maps {1} and {2} are not equal", String(left), String(right)))
            }

            if(val is Map){
                Assert.IsType(right[key], Map)
                Assert.MapsEqual(val, right[key])
            }
            else if(val is Array){
                Assert.IsType(right[key], Array)
                Assert.ArraysEqual(val, right[key])
            }
            else if(left[key] != right[key]){
                throw Error(Format("Maps {1} and {2} are not equal", String(left), String(right)))
            }
        }
    }

    /**
     * Aser that two arrays are structurally equivalent (that is, for every index, left == right or left and right
     * are structurally equivalent collections of the same type)
     * @param {Array<Any>} left 
     * @param {Array<Any>} right 
     */
    static ArraysEqual(left, right){
        if(left.length != right.length){
            throw Error(Format("Arrays {1} and {2} are not equal", String(left), String(right)))
        }

        Loop(left.length){
            if(left[A_Index] is Map){
                Assert.IsType(right[A_Index], Map)
                Assert.MapsEqual(left[A_Index], right[A_Index])
            }
            else if(left[A_Index] is Array){
                Assert.IsType(right[A_Index], Array)
                Assert.ArraysEqual(left[A_Index], right[A_Index])
            }
            else if(left[A_Index] != right[A_Index]){
                throw Error(Format("Arrays {1} and {2} differ at index {3}", String(left), String(right), A_Index))
            }
        }
    }

    /**
     * Assert that `val` is an object of type `expected` according to the `is` operator
     * @param {Any} val object to check 
     * @param {Class} expected its expected type 
     */
    static IsType(val, expected){
        if(!(val is expected)){
            throw TypeError(Format("Expected a(n) {1} but got a(n) {2}", expected.Prototype.__Class, Type(val)), , String(val))
        }
    }

    /**
     * Assert that `expr` is truthy (to check for the "real" boolean values, use `Assert.Equals(expr, 1)`)
     * @param expr 
     */
    static Truthy(expr) {
        if(!expr)
            throw ValueError("Expected a truthy value", , expr)
    }

    /**
     * Assert that `expr` is falsy (to check for the "real" boolean values, use `Assert.Equals(expr, 0)`)
     * @param expr 
     */
    static Falsy(expr) {
        if(!expr)
            throw ValueError("Expected a falsy value", , expr)
    }

    /**
     * Assert that haystack contains needle
     * @param {String} haystack string to search
     * @param {String} needle string to search for
     * @param {Boolean} caseSense whether the search is case-sensitive or not 
     */
    static InStr(haystack, needle, caseSense := false) {
        if(!InStr(haystack, needle, caseSense)) {
            Throw ValueError(Format("Expected '{1}' to contain '{2}' ({3})", 
                haystack, needle, caseSense ? "case-sensitive" : "case-insensitive"))
        }
    }

    /**
     * Assert that haystack does not contain needle
     * @param {String} haystack string to search
     * @param {String} needle string to search for
     * @param {Boolean} caseSense whether the search is case-sensitive or not 
     */
    static NotInStr(haystack, needle, caseSense := false) {
        if(InStr(haystack, needle, caseSense)) {
            Throw ValueError(Format("Expected '{1}' to not contain '{2}' ({3})", 
                haystack, needle, caseSense ? "case-sensitive" : "case-insensitive"))
        }
    }

    /**
     * Assert that `value >= min`
     * @param {Number} value 
     * @param {Number} min 
     */
    static AtLeast(value, min) {
        if(value < min)
            throw ValueError("Expected a value >= " min " but got " value)
    }

    /**
     * Assert that `value <= max`
     * @param {Number} value 
     * @param {Number} max 
     */
    static AtMost(value, max) {
        if(value > max)
            throw ValueError("Expected a value <= " max " but got " value)
    }

    /**
     * Assert that `max >= value >= min`
     * @param {Number} value 
     * @param {Number} min 
     * @param {Number} max 
     */
    static InRange(value, min, max) {
        if(value < min || value > max) {
            throw ValueError("Expected a value >= " min " and <= " max " but got " value)
        }
    }
}
#Requires AutoHotkey v2.0

;Extension methods that ensure all objects have a somewhat-useful ToString() method

MapToString(thisMap){
    str := "{"
    for(key, value in thisMap){
        str .= String(key) . ": " . String(value)
        if(A_Index < thisMap.Count){
            str .= ", "
        }
    }

    str .= "}"
    return str
}

ArrayToString(thisArr){
    str := "["

    for(value in thisArr){
        str .= String(value)
        if(A_Index < thisArr.Length){
            str .= ", "
        }
    }

    str .= "]"
    return str
}

ObjToString(thisObj){

    foundProps := Map()

    obj := thisObj

    while(obj.__Class != "Any"){
        for(name, value in ObjOwnProps(obj)){
            if(!foundProps.Has(name)){
                foundProps[name] := value
            }
        }
        obj := ObjGetBase(obj)
    }
    
    return Type(thisObj) . " " . String(foundProps)
}

BufferToString(thisBuf){
    hex := "", VarSetStrCapacity(&hex, thisBuf.size * 3)

    Loop(thisBuf.size){
        byte := NumGet(thisBuf, A_Index - 1, "char") & 0xFF
        hex .= Format(" {1:02X}", byte)
    }

    return Format("Buffer<{1} @ 0x{2:0X}>{3}", thisBuf.size, thisBuf.ptr, hex)
}

Object.Prototype.DefineProp("ToString", {Call: (self) => ObjToString(self)})
Array.Prototype.DefineProp("ToString", {Call: (self) => ArrayToString(self)})
Map.Prototype.DefineProp("ToString", {Call: (self) => MapToString(self)})
Buffer.Prototype.DefineProp("ToString", {Call: (self) => BufferToString(self)})
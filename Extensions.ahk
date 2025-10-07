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

Object.Prototype.DefineProp("ToString", {Call: (self) => ObjToString(self)})
Array.Prototype.DefineProp("ToString", {Call: (self) => ArrayToString(self)})
Map.Prototype.DefineProp("ToString", {Call: (self) => MapToString(self)})
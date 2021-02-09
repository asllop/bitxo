
//dump(CommandLine.arguments)

// TODO: variables

var last_object_id : Int64 = 1

class BXOObject {
    public var object_id : Int64

    public init() {
        self.object_id = last_object_id
        last_object_id = last_object_id + 1
    }
}

class BXOInteger : BXOObject  {
    public var integer : Int64

    public init(_ integer : Int64) {
        self.integer = integer
    }
}

class BXOFloat : BXOObject {
    public var float : Double

    public init(_ float : Double) {
        self.float = float
    }
}

class BXOString : BXOObject {
    public var string : String

        public init(_ string : String) {
        self.string = string
    }
}

class BXOSymbol : BXOObject {
    public var symbol : String

    public init(_ symbol : String) {
        self.symbol = symbol
    }
}

class BXOSelector : BXOObject {
    public var function : String
    public var object : BXOObject

    public init(_ object: BXOObject, _ function: String) {
        self.object = object
        self.function = function
    }
}

class BXOList : BXOObject {
    public var list : [BXOObject]
    public let eval : Bool

    public init(_ list : [BXOObject], _ eval : Bool = true) {
        self.list = list
        self.eval = eval
    }
}

func LOG(_ obj: BXOObject, _ level: Int = 0) {
    if let int = obj as? BXOInteger {
        print("<Integer: ID = \(int.object_id), value = \(int.integer)>")
    }
    else if let flt = obj as? BXOFloat {
        print("<Float: ID = \(flt.object_id), value = \(flt.float)>")
    }
    else if let str = obj as? BXOString {
        print("<String: ID = \(str.object_id), value = \(str.string)>")
    }
    else if let sym = obj as? BXOSymbol {
        print("<Symbol: ID = \(sym.object_id), value = \(sym.symbol)>")
    }
    else if let sel = obj as? BXOSelector {
        print("<Selector: ID = \(sel.object_id), object = \(BXOTYPE(sel.object)), function = \(sel.function)>")
    }
    else if let lst = obj as? BXOList {
        print("<List: ID = \(lst.object_id), eval = \(lst.eval), value = [")
        for content in lst.list {
            for _ in 0..<level+1 {
                print("    ", terminator: "")
            }
            LOG(content, level + 1)
        }
        for _ in 0..<level {
            print("    ", terminator:"")
        }
        print("]>")
    }
    else {
        print("<Object: ID = \(obj.object_id)>")
    }
}

func BXOTYPE(_ obj: BXOObject) -> String {
    var ret = ""
    if obj is BXOInteger {
        ret = "Integer"
    }
    else if obj is BXOFloat {
        ret = "Float"
    }
    else if obj is BXOString {
        ret = "String"
    }
    else if obj is BXOSymbol {
        ret = "Symbol"
    }
    else if obj is BXOSelector {
        ret = "Selector"
    }
    else if obj is BXOList {
        ret = "List"
    }
    else {
        ret = "Object"
    }
    return "<\(ret), ID = \(obj.object_id)>"
}

/*
(1.1 "Hola amic" 99 #hola ["Hola ":+ "Andreu"])
*/
let list = BXOList([BXOFloat(1.1), BXOString("Hola amic"), BXOInteger(99), BXOSymbol("#hola"), BXOList([BXOSelector(BXOString("Hola "), "+"), BXOString("Andreu")], false)])

LOG(list)


//dump(CommandLine.arguments)

//TODO: Implement variables: entities inside a BXOObject linked to an object
//TODO: Implement functions (selectors): entities inside a BXOObject linked to a BXOList
//NOTE: variables and functions can be the same actually.
//TODO: Implement eval method, takes a BXOList and executes it
//TODO: Implement parse method, takes code and generates a BXOList (the tree representation)

/*
entity_table: it contains variables (Int, Float, String, Symbol) and functions (List) of an object.
environment: it contains a reference to the parent object, for functions (List) that are inside the entity_table.
*/

class BXOObject : CustomStringConvertible {
    private static var next_object_id : Int64 = 1

    public var object_id : Int64
    public var native_functions : [String:([BXOObject]) -> BXOObject] = [:]
    public var entity_table : [String:BXOObject] = [:]
    //public weak var environment : BXOObject?

    public init() {
        self.object_id = BXOObject.next_object_id
        BXOObject.next_object_id = BXOObject.next_object_id + 1

        // Init native functions
        self.native_functions["def"] = self._def_
    }

    var description: String {
        return "\(type(of: self))<\(self.object_id)>"
    }

    public func _def_(args: [BXOObject]) -> BXOObject {
        if args.count == 2 {
            if let symbol = args[1] as? BXOSymbol {
                entity_table[symbol.symbol] = args[0]
            }
        }
        //TODO: if arguments are not correct, throw exception
        //TODO: native functions should be able to return nothing: Return BXOVoid?
        return BXOVoid()
    }
}

class BXOInteger : BXOObject  {
    public var integer : Int64

    public init(_ integer : Int64) {
        self.integer = integer
        super.init()

        // Init native functions
        self.native_functions["+"] = self._plus_
        self.native_functions["-"] = self._minus_
        self.native_functions["*"] = self._multiply_
        self.native_functions["/"] = self._divide_
        self.native_functions["%"] = self._reminder_
    }

    public func _plus_(args: [BXOObject]) -> BXOObject {
        var res : Int64 = self.integer
        for i in args {
            if let bxoInt = i as? BXOInteger {
                res = res + bxoInt.integer
            }
        }
        return BXOInteger(res)
    }

    public func _minus_(args: [BXOObject]) -> BXOObject {
        var res : Int64 = self.integer
        for i in args {
            if let bxoInt = i as? BXOInteger {
                res = res - bxoInt.integer
            }
        }
        return BXOInteger(res)
    }

    public func _multiply_(args: [BXOObject]) -> BXOObject {
        var res : Int64 = self.integer
        for i in args {
            if let bxoInt = i as? BXOInteger {
                res = res * bxoInt.integer
            }
        }
        return BXOInteger(res)
    }

    public func _divide_(args: [BXOObject]) -> BXOObject {
        var res : Int64 = self.integer
        for i in args {
            if let bxoInt = i as? BXOInteger {
                res = res / bxoInt.integer
            }
        }
        return BXOInteger(res)
    }

    public func _reminder_(args: [BXOObject]) -> BXOObject {
        var res : Int64 = self.integer
        for i in args {
            if let bxoInt = i as? BXOInteger {
                res = res % bxoInt.integer
            }
        }
        return BXOInteger(res)
    }
}

class BXOFloat : BXOObject {
    public var float : Double

    public init(_ float : Double) {
        self.float = float
    }
}

class BXOBoolean : BXOObject {
    public var boolean : Bool

    public init(_ boolean : Bool) {
        self.boolean = boolean
    }
}

class BXOVoid : BXOObject {}

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

class BXOVariable : BXOObject {
    public var name : String

    public init(_ name: String) {
        self.name = name
    }
}

class BXOList : BXOObject {
    public var list : [BXOObject]
    public let literal : Bool

    public init(_ list : [BXOObject], _ literal : Bool = false) {
        self.list = list
        self.literal = literal
    }
}

var stacks : [[BXOObject]] = []

func addStack() {
    print("Add Stack")
    stacks.append([])
}

func removeStack() -> [BXOObject] {
    print("Remove Stack")
    return stacks.removeLast()
}

func push(value: BXOObject) {
    if stacks.count > 0 {
        stacks[stacks.count - 1].append(value)
    }
}

func exec(stack: [BXOObject]) {
    if stack.count > 0 {
        if let sel = stack[0] as? BXOSelector {
            print("Run selector = ", terminator: "")
            LOG(sel)
            if let function = sel.object.native_functions[sel.function] {
                let res = function(Array(stack[1...]))
                push(value: res)

                print("REST = ", terminator: "")
                LOG(res)
            }
            else {
                print("TODO: NO NATIVE FUNCTION FOUND IN OBJECT, TRY DEFINED.")
                //TODO: if defined, then is a list, call eval
                //TODO: push returned value to current stack
            }
        }
        else {
            print("No selector, return last element")
            //push last element to the current stack
            push(value: stack[stack.count - 1])
        }
    }
}

func eval(list: BXOList) {
    addStack()
    for obj in list.list {
        if let lst = obj as? BXOList, lst.literal == false {
            eval(list: lst)
        }
        else {
            // Store object in current stack
            push(value: obj)
            print("Push = ", terminator: "")
            LOG(obj)
        }
    }
    let lastStack = removeStack()
    print("Last Stack = \(lastStack)")
    exec(stack: lastStack)
}

func LOG(_ obj: BXOObject, _ level: Int = 0) {
    if let int = obj as? BXOInteger {
        print("<Integer: ID = \(int.object_id), integer = \(int.integer)>")
    }
    else if let flt = obj as? BXOFloat {
        print("<Float: ID = \(flt.object_id), float = \(flt.float)>")
    }
    else if let str = obj as? BXOString {
        print("<String: ID = \(str.object_id), string = \(str.string)>")
    }
    else if let sym = obj as? BXOSymbol {
        print("<Symbol: ID = \(sym.object_id), symbol = #\(sym.symbol)>")
    }
    else if let sel = obj as? BXOSelector {
        print("<Selector: ID = \(sel.object_id), object = \(BXOTYPE(sel.object)), function = \(sel.function)>")
    }
    else if let vari = obj as? BXOVariable {
        print("<Variable: ID = \(vari.object_id), name = \(vari.name)>")
    }
    else if let lst = obj as? BXOList {
        print("<List: ID = \(lst.object_id), eval = \(lst.literal), list = [")
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
    else if obj is BXOVariable {
        ret = "Variable"
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
"The following code corresponds to the defined list structure below"
(obj:foo 15 (10:+ 1) (100:+ (5:+ 2)) ['Andreu' 0.9999])
*/
let list1 = BXOList([
    BXOSelector(BXOVariable("obj"), "foo"),
    BXOInteger(15),
    BXOList([
        BXOSelector(BXOInteger(10), "+"),
        BXOInteger(1)
    ]),
    BXOList([
        BXOSelector(BXOInteger(100), "+"),
        BXOList([
            BXOSelector(BXOInteger(5), "+"),
            BXOInteger(2)
        ]),
    ]),
    BXOList([
        BXOString("Andreu"),
        BXOFloat(0.9999)
    ], true),
])

LOG(list1)
print("-----------------------------")
eval(list: list1)

print()
print("==============================")
print()

/*
"The following code corresponds to the defined list structure below"
(1:* 1 (1 2) (3 4 5) (obj:def [1 2 3] #foo))
*/
let list2 = BXOList([
    BXOSelector(BXOInteger(1), "*"),
    BXOInteger(1),
    BXOList([
        BXOInteger(1),
        BXOInteger(2)
    ]),
    BXOList([
        BXOInteger(3),
        BXOInteger(4),
        BXOInteger(5)
    ]),
    BXOList([
        BXOSelector(BXOVariable("obj"), "def"),
        BXOList([
            BXOInteger(1),
            BXOInteger(2),
            BXOInteger(3)
        ], true),
        BXOSymbol("foo")
    ])
])

LOG(list2)
print("-----------------------------")
eval(list: list2)
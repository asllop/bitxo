//TODO: Implement parse method, takes code and generates a BXOList (the tree representation)
//TODO: Exceptions

class BXOObject : CustomStringConvertible {
    private static var next_object_id : Int64 = 1

    public var object_id : Int64
    public var native_functions : [String:([BXOObject]) -> BXOObject] = [:]
    public var entity_table : [String:BXOObject] = [:]

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
            if let symbol = args[0] as? BXOSymbol {
                entity_table[symbol.symbol] = args[1]
            }
            if let lst = args[1] as? BXOList {
                lst.self_object = self
            }
        }
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
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOInteger(self.integer + i.integer)
        }
        return BXOVoid()
    }

    public func _minus_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOInteger(self.integer - i.integer)
        }
        return BXOVoid()
    }

    public func _multiply_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOInteger(self.integer * i.integer)
        }
        return BXOVoid()
    }

    public func _divide_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOInteger(self.integer / i.integer)
        }
        return BXOVoid()
    }

    public func _reminder_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOInteger(self.integer % i.integer)
        }
        return BXOVoid()
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
    public enum VarType: Int {
        case ThisVar = 0
        case SelfVar = 1
        case NormalVar = 2
    }
    public var name : String
    public var type : VarType

    public init(_ name: String = "", type: VarType = VarType.NormalVar) {
        self.name = name
        self.type = type
    }
}

class BXOList : BXOObject {
    public var list : [BXOObject]
    public let literal : Bool
    // Object where the List resides (if it is a defined function)
    public weak var self_object : BXOObject? = nil
    // Local environment
    public weak var this_env : BXOList? = nil

    public init(_ list : [BXOObject], _ literal : Bool = false) {
        self.list = list
        self.literal = literal
    }
}

var stacks : [[BXOObject]] = []

func pushStack() {
    stacks.append([])
}

func popStack() -> [BXOObject] {
    return stacks.removeLast()
}

func push(value: BXOObject) {
    if stacks.count > 0 {
        stacks[stacks.count - 1].append(value)
    }
}

func pop() {
    if stacks.count > 0 {
        if stacks[stacks.count - 1].count > 0 {
            stacks[stacks.count - 1].removeLast()
        }
    }
}

func exec(stack: [BXOObject], list: BXOList) {
    if stack.count > 0 {
        if let sel = stack[0] as? BXOSelector {
            if let function = sel.object.native_functions[sel.function] {
                let res = function(Array(stack[1...]))
                if !(res is BXOVoid) {
                    push(value: res)
                }
                print("Executed function \(sel.function) on \(sel.object) , result = ", terminator: "")
                LOG(res)
            }
            else {
                print("TODO: NO NATIVE FUNCTION FOUND IN OBJECT, TRY DEFINED.")
                //TODO: if defined, then is a list, call eval
                //TODO: push returned value to current stack
            }
        }
        else {
            //Push last element to the current stack. Check if last element exist, stack may be empty if BXOVoid is returned
            if stack.count > 0 {
                push(value: stack[stack.count - 1])
            }
        }
    }
}

func obtain(variable: BXOVariable, list: BXOList) -> BXOObject {
    switch variable.type {
    case .ThisVar:
        if let this = list.this_env {
            return this
        }
    case .SelfVar:
        //TODO: if "self" return current "object"
        return BXOVoid()
    default:
        //TODO: if variable not in local environment, find it inside "object"
        var currList : BXOList? = list.this_env
        while currList != nil {
            if let content = currList!.entity_table[variable.name] {
                return content
            }
            else {
                currList = currList!.this_env
            }
        }
    }

    return BXOVoid()
}

//TODO: support calling selectors on an evaluable list -> ((9:+ 1):print)
//      this should first evaluate the list, and then call the function on the resulting object
//      If updating the eval function is too complicated, we could just substitute the code
//      on parse time and add an intermediate step:
/*
(
    (this:def #tmp_var (9:+ 1))
    (tmp_var:print)
)
*/

func eval(list: BXOList) {
    pushStack()
    for var obj in list.list {
        if let lst = obj as? BXOList, lst.literal == false {
            // Next object is an evaluable list, assign env and call eval with new list
            lst.this_env = list
            eval(list: lst)
        }
        else {
            // If selector with variable, get content and put in the selector
            if let sel = obj as? BXOSelector, let v = sel.object as? BXOVariable {
                let content = obtain(variable: v, list: list)
                sel.object = content
                obj = sel
            }
            // Store object in current stack
            if let v = obj as? BXOVariable {
                let content = obtain(variable: v, list: list)
                push(value: content)
            }
            else {
                push(value: obj)
            }
        }
    }
    let lastStack = popStack()
    exec(stack: lastStack, list: list)
}

func LOG(_ obj: BXOObject, _ level: Int = 0) {
    if let int = obj as? BXOInteger {
        print("<Integer: ID = \(int.object_id), integer = \(int.integer)>")
    }
    else if let flt = obj as? BXOFloat {
        print("<Float: ID = \(flt.object_id), float = \(flt.float)>")
    }
    else if let bol = obj as? BXOBoolean {
        print("<Boolean: ID = \(bol.object_id), boolean = \(bol.boolean)>")
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
    else if obj is BXOVoid {
        print("<Void>")
    }
    else if let lst = obj as? BXOList {
        print("<List: ID = \(lst.object_id), literal = \(lst.literal), list = [")
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
(
    (this:def #numA 10)

    (
        (this:def #numB 20)
        (numA:+ numB) "Return 30"
    )

    "Here numB doesn't exist"
    (numA:+ numB) "Call + with a Void argument"
    (numB:+ numA) "Try to call + on a Void object"
)
*/
let list3 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("numA"),
        BXOInteger(10)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable(type: .ThisVar), "def"),
            BXOSymbol("numB"),
            BXOInteger(20)
        ]),
        BXOList([
            BXOSelector(BXOVariable("numA"), "+"),
            BXOVariable("numB")
        ])
    ]),
    BXOList([
        BXOSelector(BXOVariable("numA"), "+"),
        BXOVariable("numB")
    ]),
    BXOList([
        BXOSelector(BXOVariable("numB"), "+"),
        BXOVariable("numA")
    ])
])

let program = list3
LOG(program)
print("-----------------------------")
eval(list: program)

print("Final stack state = \(stacks)")
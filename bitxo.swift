//TODO: check the type of an object: implement "type" method that returns string.
//TODO: "def" in basic types: Object, Integer, Float, String, Boolean, Symbol, List.
//      create a static entity_table (type_entity_table) for each class, that will hold type level defs.
//TODO: create instances, copy of a class/object
//TODO: Implement parse method, takes code and generates a BXOList (the tree representation)
//TODO: Exceptions
//TODO: interface with host app
//TODO: memory management: make sure one instance can't be in 2 places, when passing an object, always make a copy.
//TODO: always use pop_object selectors

import Foundation

class BXOObject : CustomStringConvertible {
    private static var next_object_id : Int64 = 1

    public var object_id : Int64
    public var native_functions : [String:([BXOObject]) -> BXOObject] = [:]
    public var entity_table : [String:BXOObject] = [:]
    // Environment where the object resides
    public weak var self_object : BXOObject? = nil

    public init() {
        self.object_id = BXOObject.next_object_id
        BXOObject.next_object_id = BXOObject.next_object_id + 1

        // Init native functions
        self.native_functions["def"] = self._def_
        self.native_functions["key"] = self._key_
        self.native_functions["id"] = self._id_
        self.native_functions["env"] = self._env_
    }

    var description: String {
        return "\(type(of: self))<\(self.object_id)>"
    }

    public func _def_(args: [BXOObject]) -> BXOObject {
        if args.count > 1 {
            if let symbol = args[0] as? BXOSymbol {
                args[1].self_object = self
                entity_table[symbol.symbol] = args[1]
            }
        }
        return BXOVoid()
    }

    public func _key_(args: [BXOObject]) -> BXOObject {
        if args.count > 0 {
            if let sym = args[0] as? BXOSymbol {
                if let entity = self.entity_table[sym.symbol] {
                    return entity
                }
            }
        }
        return BXOVoid()
    }

    public func _id_(args: [BXOObject]) -> BXOObject {
        return BXOInteger(self.object_id)
    }

    public func _env_(args: [BXOObject]) -> BXOObject {
        if let self_object = self.self_object {
            return self_object
        }
        return  BXOVoid()
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
        self.native_functions["="] = self._equal_
        self.native_functions["<"] = self._smaller_
        self.native_functions["set"] = self._set_
        self.native_functions["str"] = self._str_
        self.native_functions["float"] = self._float_

        //TESTING: should be defined in bitxo -> (Integer:def #print [(self:str):print])
        self.native_functions["print"] = self._print_
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

    public func _equal_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOBoolean(self.integer == i.integer)
        }
        return BXOVoid()
    }

    public func _smaller_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            return BXOBoolean(self.integer < i.integer)
        }
        return BXOVoid()
    }

    public func _set_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let i = args[0] as? BXOInteger {
            self.integer = i.integer
        }
        return BXOVoid()
    }

    public func _str_(args: [BXOObject]) -> BXOObject {
        return BXOString("\(self.integer)")
    }

    public func _float_(args: [BXOObject]) -> BXOObject {
        return BXOFloat(Double(self.integer))
    }

    //TESTING
    public func _print_(args: [BXOObject]) -> BXOObject {
        print("PRINT >>>>>>>>>>> \(self.integer)")
        return BXOVoid()
    }
}

class BXOFloat : BXOObject {
    public var float : Double

    public init(_ float : Double) {
        self.float = float
        super.init()

        // Init native functions
        self.native_functions["+"] = self._plus_
        self.native_functions["-"] = self._minus_
        self.native_functions["*"] = self._multiply_
        self.native_functions["/"] = self._divide_
        self.native_functions["="] = self._equal_
        self.native_functions["<"] = self._smaller_
        self.native_functions["set"] = self._set_
        self.native_functions["str"] = self._str_
        self.native_functions["int"] = self._int_
    }

    public func _plus_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            return BXOFloat(self.float + f.float)
        }
        return BXOVoid()
    }

    public func _minus_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            return BXOFloat(self.float - f.float)
        }
        return BXOVoid()
    }

    public func _multiply_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            return BXOFloat(self.float * f.float)
        }
        return BXOVoid()
    }

    public func _divide_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            return BXOFloat(self.float / f.float)
        }
        return BXOVoid()
    }

    public func _equal_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            return BXOBoolean(self.float == f.float)
        }
        return BXOVoid()
    }

    public func _smaller_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            return BXOBoolean(self.float < f.float)
        }
        return BXOVoid()
    }

    public func _set_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let f = args[0] as? BXOFloat {
            self.float = f.float
        }
        return BXOVoid()
    }

    public func _str_(args: [BXOObject]) -> BXOObject {
        // Optional argument, format, using printf %f syntax.
        if args.indices.contains(0), let format = args[0] as? BXOString {
            let s = NSString(format: format.string as NSString, self.float)
            return BXOString(s as String)
        }
        else {
            return BXOString("\(self.float)")
        }
    }

    public func _int_(args: [BXOObject]) -> BXOObject {
        return BXOInteger(Int64(self.float))
    }
}

class BXOBoolean : BXOObject {
    public var boolean : Bool

    public init(_ boolean : Bool) {
        self.boolean = boolean
        super.init()

        // Init native functions
        self.native_functions["and"] = self._and_
        self.native_functions["or"] = self._or_
        self.native_functions["not"] = self._not_
    }

    public func _and_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let b = args[0] as? BXOBoolean {
            return BXOBoolean(self.boolean && b.boolean)
        }
        return BXOVoid()
    }

    public func _or_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let b = args[0] as? BXOBoolean {
            return BXOBoolean(self.boolean || b.boolean)
        }
        return BXOVoid()
    }

    public func _not_(args: [BXOObject]) -> BXOObject {
        return BXOBoolean(!self.boolean)
    }
}

class BXOString : BXOObject {
    public var string : String

        public init(_ string : String) {
        self.string = string
        super.init()

        // Init native functions
        //TODO: string primitives: size, =, +, set, at, put, add, rem
        self.native_functions["sym"] = self._sym_
        self.native_functions["print"] = self._print_
    }

    public func _sym_(args: [BXOObject]) -> BXOObject {
        return BXOSymbol(self.string)
    }

    public func _print_(args: [BXOObject]) -> BXOObject {
        print("\(self.string)")
        return BXOVoid()
    }
}

class BXOSymbol : BXOObject {
    public var symbol : String

    public init(_ symbol : String) {
        self.symbol = symbol
        super.init()

        // Init native functions
        self.native_functions["str"] = self._str_
    }

    public func _str_(args: [BXOObject]) -> BXOObject {
        return BXOString(self.symbol)
    }
}

class BXOSelector : BXOObject {
    public var function : String
    public var object : BXOObject
    public var pop_object : Bool

    public init(_ object: BXOObject, _ function: String, _ pop_object : Bool = false) {
        self.object = object
        self.function = function
        self.pop_object = pop_object
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

class BXOVoid : BXOObject {}

class BXOList : BXOObject {
    public var list : [BXOObject]
    public let literal : Bool
    // Local environment
    public weak var this_env : BXOList? = nil

    public init(_ list : [BXOObject], _ literal : Bool = false) {
        self.list = list
        self.literal = literal
        super.init()

        // Init native functions
        self.native_functions["if"] = self._if_
        self.native_functions["if-else"] = self._ifelse_
        self.native_functions["while"] = self._while_
        self.native_functions["at"] = self._at_
        self.native_functions["put"] = self._put_
        self.native_functions["add"] = self._add_
        self.native_functions["rem"] = self._rem_
        self.native_functions["size"] = self._size_
    }

    public func _if_(args: [BXOObject]) -> BXOObject {
        var newargs = args
        newargs.append(BXOList([]))
        return _ifelse_(args: newargs)
    }

    public func _ifelse_(args: [BXOObject]) -> BXOObject {
        var cond = true
        // Eval condition
        eval(list: self)
        if let b = pop() as? BXOBoolean {
            cond = b.boolean
        }
        else {
            return BXOVoid() //TODO: exception
        }

        if args.count >= 2, let if_l = args[0] as? BXOList, let else_l = args[1] as? BXOList {
            if cond {
                if_l.this_env = this_env
                eval(list: if_l)
            }
            else {
                else_l.this_env = this_env
                eval(list: else_l)
            }
        }
        else {
            return BXOVoid() //TODO: exception
        }

        return BXOVoid()
    }

    public func _while_(args: [BXOObject]) -> BXOObject {
        var do_loop = true
        while do_loop {
            // Eval condition
            eval(list: self)
            if let b = pop() as? BXOBoolean {
                do_loop = b.boolean
            }
            else {
                return BXOVoid() //TODO: exception
            }

            if do_loop {
                if args.count >= 1, let l = args[0] as? BXOList {
                    // Run loop body
                    l.this_env = this_env
                    eval(list: l)
                }
                else {
                    return BXOVoid() //TODO: exception
                }
            }
        }

        return BXOVoid()
    }

    public func _at_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let index = args[0] as? BXOInteger {
            if list.count > index.integer {
                return list[Int(index.integer)]
            }
        }
        return BXOVoid() //TODO: exception
    }

    public func _put_(args: [BXOObject]) -> BXOObject {
        if args.count > 1, let index = args[0] as? BXOInteger {
            if list.count > index.integer {
                list[Int(index.integer)] = args[1]
            }
        }
        return BXOVoid()
    }

    public func _add_(args: [BXOObject]) -> BXOObject {
        if args.count > 0 {
            list.append(args[0])
        }
        return BXOVoid()
    }

    public func _rem_(args: [BXOObject]) -> BXOObject {
        if args.count > 0, let index = args[0] as? BXOInteger {
            if list.count > index.integer {
                return list.remove(at: Int(index.integer))
            }
        }
        return BXOVoid() //TODO: exception
    }

    public func _size_(args: [BXOObject]) -> BXOObject {
        return BXOInteger(Int64(list.count))
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

func pop() -> BXOObject? {
    if stacks.count > 0 {
        if stacks[stacks.count - 1].count > 0 {
            return stacks[stacks.count - 1].removeLast()
        }
    }
    return nil
}

func exec(stack: [BXOObject], list: BXOList) {
    if stack.count > 0 {
        if let sel = stack[0] as? BXOSelector {
            // If object of selector is a list, set this_env
            if let lst_obj = sel.object as? BXOList {
                print("Object of selector is a list, set this_env")
                lst_obj.this_env = list
            }

            if let function = sel.object.native_functions[sel.function] {
                // Execute native function
                let res = function(Array(stack[1...]))
                if !(res is BXOVoid) {
                    push(value: res)
                }
                print("Executed function \(sel.function) on \(sel.object) , result = ", terminator: "")
                LOG(res)
            }
            else {
                if let entity = sel.object.entity_table[sel.function] {  
                    if let lst = entity as? BXOList {
                        // Execute defined function
                        print("Execute defined function \(sel.function) = \(lst) , stack = \(stack)")
                        // Pass the stack (arguments) to the defined function inside a variable "args"
                        lst.entity_table["args"] = BXOList(Array(stack[1...]), true)
                        eval(list: lst)
                        lst.entity_table.removeValue(forKey: "args")
                    }
                    else {
                        // If not a list, return the value (put in stack)
                        push(value: entity)
                    }
                }
            }
        }
        else {
            if stack.count > 1, let sel = stack[1] as? BXOSelector, sel.pop_object == true {
                print("Exec selector with pop_object \(sel) = \(stack)")
                // Pop stack[0], set it into selector object and call exec with modified stack
                var s = stack
                sel.object = s.remove(at: 0)
                exec(stack: s, list: list)
            }
            else {
                //Push last element to the current stack. Check if last element exist, stack may be empty if BXOVoid is returned
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
        var currList : BXOList? = list
        while currList != nil {
            if let s = currList!.self_object {
                return s
            }
            else {
                currList = currList!.this_env
            }
        }
    default:
        var self_object : BXOObject? = nil
        var currList : BXOList? = list//.this_env
        while currList != nil {
            if let content = currList!.entity_table[variable.name] {
                return content
            }
            else {
                self_object = currList!.self_object
                currList = currList!.this_env
            }
        }
        // If variable not in local environment, find it inside "object"
        if let s = self_object, let content = s.entity_table[variable.name] {
            return content
        }
    }

    return BXOVoid()
}

func eval(list: BXOList) {
    pushStack()
    for obj in list.list {
        if let lst = obj as? BXOList, lst.literal == false {
            // Next object is an evaluable list, assign env and call eval with new list
            lst.this_env = list
            eval(list: lst)
        }
        else {
            // If selector with variable, get content and put in the selector
            if let sel = obj as? BXOSelector, let v = sel.object as? BXOVariable {
                sel.object = obtain(variable: v, list: list)
            }
            // Store object in current stack
            if let v = obj as? BXOVariable {
                push(value: obtain(variable: v, list: list))
            }
            else {
                push(value: obj)
            }
        }
    }
    exec(stack: popStack(), list: list)
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
    else if obj is BXOBoolean {
        ret = "Boolean"
    }
    else if obj is BXOVoid {
        ret = "Void"
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
    "(numA:+ numB)" "Call + with a Void argument -> this should fire Exception"
    "(numB:+ numA)" "Try to call + on a Void object -> this should fire Exception"

    "Define inc function inside numA"
    (numA:def #myNum 66)
    (numA:def #foo [
        (self:+ 1)      "Return 1"
        (self:+ myNum)  "Return 76"
        (myNum:- self)  "Return 56"
    ])

    ((numA:foo):print)
)
*/
let list1 = BXOList([
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
    /*
    BXOList([
        BXOSelector(BXOVariable("numA"), "+"),
        BXOVariable("numB")
    ]),
    BXOList([
        BXOSelector(BXOVariable("numB"), "+"),
        BXOVariable("numA")
    ]),
    */
    BXOList([
        BXOSelector(BXOVariable("numA"), "def"),
        BXOSymbol("myNum"),
        BXOInteger(66)
    ]),
    BXOList([
        BXOSelector(BXOVariable("numA"), "def"),
        BXOSymbol("foo"),
        BXOList([
            BXOList([
                BXOSelector(BXOVariable(type: .SelfVar), "+"),
                BXOInteger(1)                
            ]),
            BXOList([
                BXOSelector(BXOVariable(type: .SelfVar), "+"),
                BXOVariable("myNum")
            ]),
            BXOList([
                BXOSelector(BXOVariable("myNum"), "-"),
                BXOVariable(type: .SelfVar)
            ])
        ], true)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("numA"), "foo"),
        ]),
        BXOSelector(BXOVoid(), "print", true),
    ])
])

/*
(
    (this:def #counter 0)
    (
        [counter:< 10]:while [
            (counter:set (counter:+ 1))
            (counter:print)
        ]
    )
)

Inside the loop block we cannot define counter again, because it will be defines inside the List of the block,
and the definition will not be accessible from other blocks (condition).

Instead, we use "set" to change value.

To resolve this problem we could create a selector that returns the local environment of any object.

    (counter:this)

So we can do:
    
    ((counter:this):def #counter (counter:+ 1))
*/

let list2 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("counter"),
        BXOInteger(0)
    ]),
    BXOList([
        BXOSelector(BXOList([
            BXOSelector(BXOVariable("counter"), "<"),
            BXOInteger(10)
        ], true), "while"),
        BXOList([
            BXOList([
                BXOSelector(BXOVariable("counter"), "print")
            ]),
            BXOList([
                BXOSelector(BXOVariable("counter"), "set"),
                BXOList([
                    BXOSelector(BXOVariable("counter"), "+"),
                    BXOInteger(1)
                ])
            ])
        ], true)
    ])
])

/*
(
    (this:def #counter 0)
    (
        [counter:< 10]:if [
            ("Counter menor que 10":print)
        ]
    )
    (
        [counter:= 10]:if-else
        [
            ("Counter igual a 10":print)
        ]
        [
            ("Counter diferent de 10":print)
        ]
    )
)
*/

let list3 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("counter"),
        BXOInteger(0)
    ]),
    BXOList([
        BXOSelector(BXOList([
            BXOSelector(BXOVariable("counter"), "<"),
            BXOInteger(10)
        ], true), "if"),
        BXOList([
            BXOList([
                BXOSelector(BXOString("Counter menor que 10"), "print")
            ])
        ], true)
    ]),
    BXOList([
        BXOSelector(BXOList([
            BXOSelector(BXOVariable("counter"), "="),
            BXOInteger(10)
        ], true), "if-else"),
        BXOList([
            BXOList([
                BXOSelector(BXOString("ounter igual a 10"), "print")
            ])
        ], true),
        BXOList([
            BXOList([
                BXOSelector(BXOString("Counter diferent de 10"), "print")
            ])
        ], true)
    ])
])

/*
(this:def #inum 10)
(this:def #fnum 9.9)
(this:def #symb #hola)

((inum:str):print)
((fnum:str):print)
((fnum:str "%.3f"):print)
((symb:str):print)
*/

let list4 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("inum"),
        BXOInteger(10)
    ]),
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("fnum"),
        BXOFloat(9.9)
    ]),
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("symb"),
        BXOSymbol("hola")
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("inum"), "str"),
        ]),
        BXOSelector(BXOVoid(), "print", true),
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("fnum"), "str"),
        ]),
        BXOSelector(BXOVoid(), "print", true),
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("fnum"), "str"),
            BXOString("%.3f")
        ]),
        BXOSelector(BXOVoid(), "print", true),
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("symb"), "str"),
        ]),
        BXOSelector(BXOVoid(), "print", true),
    ])
])

/*
(this:def #inum 10)
((((inum:+ 1):* 2):str):print)
*/

let list5 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("inum"),
        BXOInteger(10)
    ]),
    BXOList([
        BXOList([
            BXOList([
                BXOList([
                    BXOSelector(BXOVariable("inum"), "+"),
                    BXOInteger(1)
                ]),
                BXOSelector(BXOVoid(), "*", true),
                BXOInteger(2)
            ]),
            BXOSelector(BXOVoid(), "str", true)
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ])
])

/*
(this:def #list [])
(list:add 25)
(list:add 'Hola amic')
(list:add 'Adeu')
((list:at 1):print)
((list:size):print)
(list:rem 1)
((list:at 1):print)
*/

let list6 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("list"),
        BXOList([], true)
    ]),
    BXOList([
        BXOSelector(BXOVariable("list"), "add"),
        BXOInteger(25)
    ]),
    BXOList([
        BXOSelector(BXOVariable("list"), "add"),
        BXOString("Hola amic")
    ]),
    BXOList([
        BXOSelector(BXOVariable("list"), "add"),
        BXOString("Adeu")
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("list"), "at"),
            BXOInteger(1)
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("list"), "size")
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ]),
    BXOList([
        BXOSelector(BXOVariable("list"), "rem"),
        BXOInteger(1)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("list"), "at"),
            BXOInteger(1)
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("list"), "size")
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ])
])

// IMPORTANT LESSON:
// Never put a variable inside a selector, use pop_object instead because variables can changes, and
// the object inside a selector is static.
/*
(this:def #dict [])

(dict:def #age 37)
(dict:def #name 'Andreu')

((dict:age):print)
((dict:name):print)
((dict:key #name):print)
*/

let list7 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("dict"),
        BXOList([], true)
    ]),
    BXOList([
        BXOSelector(BXOVariable("dict"), "def"),
        BXOSymbol("age"),
        BXOInteger(37)
    ]),
    BXOList([
        BXOSelector(BXOVariable("dict"), "def"),
        BXOSymbol("name"),
        BXOString("Andreu")
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("dict"), "age")
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("dict"), "name")
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("dict"), "key"),
            BXOSymbol("name")
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ])
])

/*
    (this:def #num 69)
    (num:def #myprint [(self:str):print])
    (num:myprint)
    (num:def #printargs [
        ((args:size):print)
        ((args:at 0):print)
        ((args:at 1):print)
    ])
    (num:printargs 'hola' 10 false)
*/

let list8 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("num"),
        BXOInteger(69)
    ]),
    BXOList([
        BXOSelector(BXOVariable("num"), "def"),
        BXOSymbol("myprint"),
        BXOList([
            BXOList([
                BXOSelector(BXOVariable(type: .SelfVar), "str")
            ]),
            BXOSelector(BXOVoid(), "print", true)
        ], true)
    ]),
    BXOList([
        BXOSelector(BXOVariable("num"), "myprint")
    ]),
    BXOList([
        BXOSelector(BXOVariable("num"), "def"),
        BXOSymbol("printargs"),
        BXOList([
            BXOList([
                BXOList([
                    BXOSelector(BXOVariable("args"), "size")
                ]),
                BXOSelector(BXOVoid(), "print", true)
            ]),
            BXOList([
                BXOList([
                    BXOSelector(BXOVariable("args"), "at"),
                    BXOInteger(0)
                ]),
                BXOSelector(BXOVoid(), "print", true)
            ]),
            BXOList([
                BXOList([
                    BXOSelector(BXOVariable("args"), "at"),
                    BXOInteger(1)
                ]),
                BXOSelector(BXOVoid(), "print", true)
            ])
        ], true)
    ]),
    BXOList([
        BXOSelector(BXOVariable("num"), "printargs"),
        BXOString("hola"),
        BXOInteger(10),
        BXOBoolean(false)
    ])
])

/*
    (this:def #num 69)
    (num:def #suma [self:+ (args:at 0))
    ((num:suma 10):print)
*/

let list9 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("num"),
        BXOInteger(69)
    ]),
    BXOList([
        BXOSelector(BXOVariable("num"), "def"),
        BXOSymbol("suma"),
        BXOList([
            BXOSelector(BXOVariable(type: .SelfVar), "+"),
            BXOList([
                BXOSelector(BXOVariable("args"), "at"),
                BXOInteger(0)
            ])
        ], true)
    ]),
    BXOList([
        BXOList([
            BXOSelector(BXOVariable("num"), "suma"),
            BXOInteger(10)
        ]),
        BXOSelector(BXOVoid(), "print", true)
    ])
])

/*
    (this:def #counter 0)
    ([counter:< 10]:while [
        ((counter:env):def #counter (counter:+ 1))
        (counter:print)
    ])
    ('========================':print)
    (counter:print)
*/

let list10 = BXOList([
    BXOList([
        BXOSelector(BXOVariable(type: .ThisVar), "def"),
        BXOSymbol("counter"),
        BXOInteger(0)
    ]),
    BXOList([
        BXOSelector(BXOList([
            BXOVariable("counter"),
            BXOSelector(BXOVoid(), "<", true),
            BXOInteger(10)
        ], true), "while"),
        BXOList([
            BXOList([
                BXOList([
                    BXOVariable("counter"),
                    BXOSelector(BXOVoid(), "env", true),
                ]),
                BXOSelector(BXOVoid(), "def", true),
                BXOSymbol("counter"),
                BXOList([
                    BXOVariable("counter"),
                    BXOSelector(BXOVoid(), "+", true),
                    BXOInteger(1)
                ])
            ]),
            BXOList([
                BXOVariable("counter"),
                BXOSelector(BXOVoid(), "print", true)
            ])
        ], true)
    ]),
    BXOList([
        BXOSelector(BXOString("========================"), "print")
    ]),
    BXOList([
        BXOSelector(BXOVariable("counter"), "print")
    ])
])

let program = list10
LOG(program)
print("-----------------------------")
eval(list: program)

print("Final stack state = \(stacks)")
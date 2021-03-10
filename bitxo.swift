//TODO: create instances, copy of a class/object
//TODO: Implement parse method, takes code and generates a BXOList (the tree representation)
//TODO: Exceptions
//TODO: interface with host app
//TODO: memory management: make sure one instance can't be in 2 places, when passing an object, always make a copy.

/*
TODO: define class functions in code.
*/

import Foundation

var type_entity_table : [String:[String:BXOObject]] = [
    "Integer":[:],
    "Float":[:],
    "Boolean":[:],
    "String":[:],
    "Symbol":[:],
    "List":[:],
    "Object":[:],
]

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
        self.native_functions["type"] = self._type_
    }

    var description: String {
        return "\(type(of: self))<\(self.object_id)>"
    }

    public func bxotype() -> String {
        return "Object"
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

    public func _type_(args: [BXOObject]) -> BXOObject {
        return BXOString(self.bxotype())
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
    }

    override public func bxotype() -> String {
        return "Integer"
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

    override public func bxotype() -> String {
        return "Float"
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

    override public func bxotype() -> String {
        return "Boolean"
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

    override public func bxotype() -> String {
        return "String"
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
        self.native_functions["sel"] = self._sel_
    }

    override public func bxotype() -> String {
        return "Symbol"
    }

    public func _str_(args: [BXOObject]) -> BXOObject {
        return BXOString(self.symbol)
    }

    public func _sel_(args: [BXOObject]) -> BXOObject {
        return BXOSelector(self.symbol)
    }
}

class BXOSelector : BXOObject {
    public var function : String

    public init(_ function: String) {
        self.function = function
    }

    override public func bxotype() -> String {
        return "Selector"
    }
}

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

    override public func bxotype() -> String {
        return "List"
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
    if stack.count > 1 {
        // stack[1] contains the selector? then stack[0] contains the object
        if let sel = stack[1] as? BXOSelector {
            // If object of selector is a list, set this_env
            if let lst_obj = stack[0] as? BXOList {
                print("Object of selector is a list, set this_env")
                lst_obj.this_env = list
            }

            if let function = stack[0].native_functions[sel.function] {
                // Execute native function
                let res = function(Array(stack[2...]))
                if !(res is BXOVoid) {
                    push(value: res)
                }
                print("Executed function \(sel.function) on \(stack[0]) , result = ", terminator: "")
                LOG(res)
            }
            else {
                if let entity = stack[0].entity_table[sel.function] {  
                    if let lst = entity as? BXOList {
                        // Execute defined function
                        print("Execute defined function \(sel.function) = \(lst) , stack = \(stack)")
                        // Pass the stack (arguments) to the defined function inside a variable "args"
                        lst.entity_table["args"] = BXOList(Array(stack[2...]), true)
                        eval(list: lst)
                        lst.entity_table.removeValue(forKey: "args")
                    }
                    else {
                        // If not a list, return the value (put in stack)
                        push(value: entity)
                    }
                }
                else if let type_entity = type_entity_table[stack[0].bxotype()]![sel.function] {
                    print("Execute class function \(sel.function) from class \(stack[0].bxotype())")
                    if let lst = type_entity as? BXOList {
                        lst.entity_table["args"] = BXOList(Array(stack[2...]), true)
                        lst.self_object = stack[0]
                        eval(list: lst)
                        lst.entity_table.removeValue(forKey: "args")
                        lst.self_object = nil
                    }
                    else {
                        // If not a list, return the value (put in stack)
                        push(value: type_entity)
                    }
                }
            }
        }
        else {
            //Push last element to the current stack.
            push(value: stack[stack.count - 1])
        }
    }
    else if stack.count == 1 {
        //Push last element to the current stack (for lists with 1 element only)
        push(value: stack[stack.count - 1])
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
        print("<Selector: ID = \(sel.object_id), function = \(sel.function)>")
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
    (this:def #counter 0)
    ([counter:< 10]:while [
        ((counter:env):def #counter (counter:+ 1))
        (counter:print)
    ])
    ('========================':print)
    (counter:print)
*/

let list1 = BXOList([
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("counter"),
        BXOInteger(0)
    ]),
    BXOList([
        BXOList([
            BXOVariable("counter"),
            BXOSelector("<"),
            BXOInteger(10)
        ], true),
        BXOSelector("while"),
        BXOList([
            BXOList([
                BXOList([
                    BXOVariable("counter"),
                    BXOSelector("env"),
                ]),
                BXOSelector("def"),
                BXOSymbol("counter"),
                BXOList([
                    BXOVariable("counter"),
                    BXOSelector("+"),
                    BXOInteger(1)
                ])
            ]),
            BXOList([
                BXOVariable("counter"),
                BXOSelector("print")
            ])
        ], true)
    ]),
    BXOList([
        BXOString("========================"),
        BXOSelector("print")
    ]),
    BXOList([
        BXOVariable("counter"),
        BXOSelector("print")
    ])
])

/*
    (this:def #num 101)
    (num (#print:sel))  "equivalent to -> (num:print). Symbol:sel is a way to generate selectors dynamically."
*/
let list2 = BXOList([
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("num"),
        BXOInteger(101)
    ]),
    BXOList([
        BXOVariable("num"),
        BXOList([
            BXOSymbol("print"),
            BXOSelector("sel")
        ])
    ])
])

/*
    (this:def #num (101))
    (num:print)
    (
        (num:print)
        (
            (num:print)
        )
        (this:def #num 99)
        (num:print)
    )
    (num:print)
    (('Hola'):print)
    ('Adeu':print)
    (num:def #suma [self:+ (args:at 0)])
    ((num:suma 10):print)
*/

let list3 = BXOList([
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("num"),
        BXOList([
            BXOInteger(101)
        ])
    ]),
    BXOList([
        BXOVariable("num"),
        BXOSelector("print")
    ]),
    BXOList([
        BXOList([
            BXOVariable("num"),
            BXOSelector("print")
        ]),
        BXOList([
            BXOList([
                BXOVariable("num"),
                BXOSelector("print")
            ])
        ]),
        BXOList([
            BXOVariable(type: .ThisVar),
            BXOSelector("def"),
            BXOSymbol("num"),
            BXOInteger(99)
        ]),
        BXOList([
            BXOVariable("num"),
            BXOSelector("print")
        ])
    ]),
    BXOList([
        BXOVariable("num"),
        BXOSelector("print")
    ]),
    BXOList([
        BXOList([
            BXOString("Hola")
        ]),
        BXOSelector("print")
    ]),
    BXOList([
        BXOString("Adeu"),
        BXOSelector("print")
    ]),
    BXOList([
        BXOVariable("num"),
        BXOSelector("def"),
        BXOSymbol("suma"),
        BXOList([
            BXOVariable(type: .SelfVar),
            BXOSelector("+"),
            BXOList([
                BXOVariable("args"),
                BXOSelector("at"),
                BXOInteger(0)
            ])
        ], true)
    ]),
    BXOList([
        BXOList([
            BXOVariable("num"),
            BXOSelector("suma"),
            BXOInteger(10)
        ]),
        BXOSelector("print")
    ])
])

/*
TODO: Example with nested if-else structure:

    (this:def #option 0)

    [option:= 0]:if-else
    [
        ('Zero':print)
    ]
    [
        [option:= 1]:if-else
        [
            ('One':print)
        ]
        [
            [option:= 2]:if-else
            [
                ('Two':print)
            ]
            [
                [option:= 3]:if-else
                [
                    ('Three':print)
                ]
                [
                    ('Other option':print)
                ]
            ]
        ]
    ]
*/

let list4 = BXOList([
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("option"),
        BXOInteger(0)
    ]),
    /*
    BXOList([
        BXOVariable("option"),
        BXOSelector("="),
        BXOInteger(0)
    ], true),
    BXOSelector("if-else"),
    BXOList([
        BXOList([
            BXOString("Zero"),
            BXOSelector("print")
        ])
    ], true),
    BXOList([
        // Else
    ], true)
    */
])

/*
    (this:def #num 101)
    (this:def #str 'hola')
    (this:def #flt 9.9)
    ((num:type):print)
    ((str:type):print)
    ((flt:type):print)
    ((this:type):print)
*/
let list5 = BXOList([
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("num"),
        BXOInteger(101)
    ]),
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("str"),
        BXOString("hola")
    ]),
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("flt"),
        BXOFloat(9.9)
    ]),
    BXOList([
        BXOList([
            BXOVariable("num"),
            BXOSelector("type")
        ]),
        BXOSelector("print")
    ]),
    BXOList([
        BXOList([
            BXOVariable("str"),
            BXOSelector("type")
        ]),
        BXOSelector("print")
    ]),
    BXOList([
        BXOList([
            BXOVariable("flt"),
            BXOSelector("type")
        ]),
        BXOSelector("print")
    ]),
    BXOList([
        BXOList([
            BXOVariable(type: .ThisVar),
            BXOSelector("type")
        ]),
        BXOSelector("print")
    ])
])

/*
    (this:def #num 101)
    (num:print)
*/
let list6 = BXOList([
    BXOList([
        BXOVariable(type: .ThisVar),
        BXOSelector("def"),
        BXOSymbol("num"),
        BXOInteger(101)
    ]),
    BXOList([
        BXOVariable("num"),
        BXOSelector("print")
    ])
])

/*
Add a type selector for Integer -> [(self:str):print]

(Integer:def #print [(self:str):print])
*/
type_entity_table["Integer"]!["print"] = BXOList([
    BXOList([
        BXOVariable(type: .SelfVar),
        BXOSelector("str")
    ]),
    BXOSelector("print")
], true)

print("\(type_entity_table)")

let program = list6
LOG(program)
print("-----------------------------")
eval(list: program)

print("Final stack state = \(stacks)")
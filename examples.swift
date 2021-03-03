
/*
"The following code corresponds to the defined list structure below"
(
    (this:def #numA 10)

    (
        (this:def #numB 20)
        (numA:+ numB) "Return 30"
    )

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
    (num:def #suma [self:+ (args:at 0)])
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
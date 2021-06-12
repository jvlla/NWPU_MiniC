
## 文法产生式

G[<program>]:
<program> → { <segment> }                                   程序由可重复的segment块组成
<segment> → <type> <def>
<type> → 'int' | 'void'                                     程序只包含int, void两种类型，所以可以有void变量？
<def> → '*' ident <deflist> | ident <idtail>                def是只是声明，不能赋值，前一半指针，后一半变量，
                                                            可以是函数定义或声明，指针没有数组
<deflist> → ','  <defdata> <deflist> | ';'                  第一个变量之后的部分
<defdata> → ident <vardef> | '*' ident                       这个是每一个变量
<vardef> → { '[' num ']' }                                 数组形式
<idtail> → <vardef> <deflist> | '(' <para> ')' <functail>  主要是后面函数定义的部分
<functail> → <block> | ';'
<para> → <onepara> { ','  <onepara> } | ε
<onepara> → <type> <paradata>
<paradata> → '*' ident | ident <paradatatail>               函数参数只能是指针或数组
<paradatatail> → '[' ']' { '[' num ']' } | { '[' num ']' }  函数里面不能写出一维数组的大小
    
下面就是函数里面的部分了
<block> → '{' <subprogram> '}'                              block是{}包含的
<subprogram> → {<onestatement>}                             可以有多个onestatement
<onestatement> → <localdef> | <statement>
<localdef> → <type> <defdata> <deflist>                     好像还是一样的
下面主要就是语句了
<statement> → <whilestat>|
    <breakstat> |
    <continuestat> |
    <ifstat> |                                              这里是加的，原来没有，得有啊，要不没人用ifstat了
    <returnstat> |
    <blockstat> |
    <assignstat> |
    <emptystat>
<breakstat> → 'break' ';'
<continuestat> → 'continue' ';'
<returnstat> → 'return' <altexpr> ';'
<assignstat> → <altexpr> ';'
<blockstat> → <block>
<emptystat> → ';'
复杂一些的statement
<whilestat> → 'while' '(' <altexpr> ')' <statement>
<ifstat> → 'if'  '(' <expr> ')'  <block> <elsestat>
<elsestat> → 'else' <block> | ε
这个以后是表达式部分，应该是有结果的那种
<altexpr> → <expr> | ε
<expr> → <assexpr>
<assexpr> → <orexpr> <asstail> 
<asstail> → '='  <assexpr>  <asstail> | ε
之后应该算主要是逻辑表达式部分，但这orexpr又可以只包含变量名，实在离谱
<orexpr> → <andexpr> <ortail>                               这个是逻辑表达式，与或非那种
<ortail> → '||' <andexpr> <ortail> | ε                      应该是||的优先级高于&&高于普通
<andexpr> → <cmpexpr> <andtail>
<andtail> → '&&' <cmpexpr> <andtail> |  ε
<cmpexpr> → <aloexpr> <cmptail>
<cmptail> → <cmps> <aloexpr> <cmptail>| ε
<cmps> → '>=' | '>' | '<' | '<=' | '==' | '!='
<aloexpr> → <item> <alotail>
<alotail> → <addsub> <item> <alotail> | ε
<addsub> → '+' | '-'
<item> → <factor> <itemtail>
<itemtail> → <muldiv> <factor> <itemtail> | ε
<muldiv> → '*' | '/'
<factor> → <lop> <factor> | <val>
<lop>  → '!' | '-' | '&' | '*' | <incr> | <decr>
<val> → <elem> [<rop>]
<rop> → <incr> | <decr>
<incr> → '++'
<decr> → '--'
<elem> → ident <idexpr> | '(' <expr> ')' | <literal>
<idexpr> → '[' <expr> ']' | '(' <realarg> ')' | ε
<literal> → num
<realarg> → <arg> {',' <arg>} | ε
<arg> → <expr>

非终结符为<>括起来的符号
[]括起来的是可选的意思(0次或1次)，{}括起来是可重复的意思)(0次或无数次)
终结符是由单引号括起的串，或者是ident 、num这样的记号
ident代表标识符，num代表整型常量

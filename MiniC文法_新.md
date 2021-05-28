
## 文法产生式

G[<program>]:
<program> → { <segment> }
<segment> → <type> <def>
<type> → 'int' | 'void'
<def> → '*' ident <deflist> | ident <idtail>
<deflist> → ','  <defdata> <deflist> | ';'
<defdata> → ident <varrdef> | '*' ident
<varrdef> → { '[' num ']' }
<idtail> → <varrdef> <deflist> | '(' <para> ')' <functail>
<functail> → <blockstat> | ';'
<para> → <onepara> { ','  <onepara> } | ε
<onepara> → <type> <paradata>
<paradata> → '*' ident | ident <paradatatail>
<paradatatail> → '[' ']' { '[' num ']' } | { '[' num ']' }
<subprogram> → { <onestatement> }
<onestatement> -> <localdef> | <statement>
<localdef> → <type> <defdata> <deflist>
<breakstat> → 'break' ';'
<continuestat> → 'continue' ';'
<returnstat> → 'return' <altexpr> ';'
<assignstat> → <altexpr> ';'
<blockstat> → '{' <subprogram> '}'
<emptystat> → ';'
<whilestat> → 'while' '(' <expr> ')' <statement>
<ifstat> → 'if'  '(' <expr> ')'  <statement> <elsestat>
<elsestat> → 'else' <statement> | ε
<statement> → <whilestat>|
    <ifstat> |
    <breakstat> |
    <continuestat> |
    <returnstat> |
    <blockstat> |
    <assignstat> |
    <emptystat>
<altexpr> → <expr> | ε
<expr> → <assexpr>
<assexpr> → <orexpr> <asstail>
<asstail> → '='  <assexpr>  <asstail> | ε
<orexpr> → <andexpr> <ortail>
<ortail> → '||' <andexpr> <ortail> | ε
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
<val> → <elem> [ <rop> ]
<rop> → <incr> | <decr>
<incr> → '++'
<decr> → '--'
<elem> → ident <idexpr> | '(' <expr> ')' | <literal>
<idexpr> → '[' <expr> ']' | '(' <realarg> ')' | ε
<literal> → num
<realarg> → <arg> {',' <arg>} | ε
<arg> → <expr>

非终结符为<>括起来的符号
终结符是由单引号括起的串，或者是 ident 、num这样的记号
ident代表标识符，num代表整型常量

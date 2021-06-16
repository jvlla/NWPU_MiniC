#include <iostream>
#include <stdio.h>
#include <cstdio>
#include <cstdlib>
#include <stdlib.h>
#include <fstream>
#include <string>
#include <string.h>

#include "SymTable/SymTable.h"
#include "SymTable/SymTableException.h"
#include "SymTable/Type.h"
#include "SymTable/Type.h"
#include "SymTable/TypeFunc.h"
#include "SymTable/Array.h"

#include "SynTree/SynTree.h"
#include "SynTree/SynNode.h"
#include "SynTree/Expr.h"
#include "SynTree/Op.h"
#include "SynTree/Unary.h"
#include "SynTree/Terminal.h"
#include "SynTree/Variable.h"
#include "SynTree/Constant.h"
#include "SynTree/Stmt.h"
#include "SynTree/If.h"
#include "SynTree/Else.h"
#include "SynTree/While.h"
#include "SynTree/Break.h"
#include "SynTree/Continue.h"
#include "SynTree/Return.h"
#include "SynTree/Func.h"
#include "SynTree/SynTreeException.h"

#include "ParserException.h"
#include "LexerException.h"

#define DEBUG  // 其实就只有helper.cpp中有一个parser_tracker()函数用于输出parser过程中递归经过了哪些非终结符

using namespace std;

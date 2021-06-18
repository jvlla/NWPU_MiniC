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
#include "SynTree/FuncCall.h"
#include "SynTree/SynTreeException.h"

#include "ParserException.h"
#include "LexerException.h"

#define DEBUG  // 设置之后可以在各阶段递归调用时输出一些参数，方便看哪里出错出异常什么的

using namespace std;

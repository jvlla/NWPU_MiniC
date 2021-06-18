#include "ParserException.h"
#include <string.h>

ParserException::ParserException(std::string message, int line)
{
    this->message_ = message;
    this->line_ = line;
}

const char * ParserException::what() const throw()
{
    std::string ret;
    char * ret_char;

    if (this->line_ == -1)
        ret = this->message_;
    else
        ret = "Line(" + std::to_string(this->line_) + "): " + this->message_;
    // 返回值要通过malloc分配，不然反正怎么就是有问题
    ret_char = (char *) malloc(strlen(ret.c_str()));
    strcpy(ret_char, ret.c_str());
    
    return (char*) ret_char;
}
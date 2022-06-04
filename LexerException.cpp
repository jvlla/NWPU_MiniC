#include "LexerException.h"
#include <iostream>
#include <string>
#include <string.h>

LexerException::LexerException(std::string message, int line)
{
    this->message_ = message;
    this->line_ = line;
}

const char * LexerException::what() const throw()
{
    std::string ret;
    char * ret_char;

    if (this->line_ == -1)
        ret = this->message_;
    else
        ret = "Line(" + std::to_string(this->line_) + "): " + this->message_;
    ret_char = (char *) malloc(strlen(ret.c_str()));
    strcpy(ret_char, ret.c_str());
    
    return (char*) ret_char;
}

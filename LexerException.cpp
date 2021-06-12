#include "LexerException.h"
#include <iostream>

LexerException::LexerException(std::string message)
{
    this->message = message;
}

const char * LexerException::what() const throw()
{
    return (char*)this->message.c_str();
}

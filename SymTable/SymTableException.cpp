#include "SymTableException.h"
#include <string>

SymTableException::SymTableException(std::string message)
{
    this->message = message;
}

const char * SymTableException::what() const throw()
{
    return (char*)this->message.c_str();
}
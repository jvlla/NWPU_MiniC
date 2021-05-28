#include "SynTreeException.h"
#include <string>

SynTreeException::SynTreeException(std::string message)
{
    this->message = message;
}

const char * SynTreeException::what() const throw()
{
    return (char*)this->message.c_str();
}
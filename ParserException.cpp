#include "ParserException.h"

ParserException::ParserException(std::string message)
{
    this->message = message;
}

const char * ParserException::what() const throw()
{
    return (char*)this->message.c_str();
}
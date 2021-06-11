#ifndef __PARSER_EXCEPTION__
#define __PARSER_EXCEPTION__
#include <exception>
#include <string>

class ParserException: public std::exception
{
  public:
    ParserException(std::string message);
	const char * what() const throw();
  private:
	  std::string message;
};

#endif
#ifndef __LEXER_EXCEPTION__
#define __LEXER_EXCEPTION__
#include <exception>
#include <string>

class LexerException: public std::exception
{
  public:
    LexerException(std::string message);
	  const char * what() const throw();
  private:
	  std::string message;
};

#endif
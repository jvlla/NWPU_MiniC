#ifndef __LEXER_EXCEPTION__
#define __LEXER_EXCEPTION__
#include <exception>
#include <string>

class LexerException: public std::exception
{
  public:
    LexerException(std::string message, int line);
	  const char * what() const throw();
  private:
	  std::string message_;  // 报错信息
    int line_;  // 错误行号，不知道行号就为-1
};

#endif
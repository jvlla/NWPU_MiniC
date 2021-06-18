#ifndef __SYM_TABLE_EXCEPTION_H__
#define __SYM_TABLE_EXCEPTION_H__
#include <exception>
#include <string>

class SymTableException: public std::exception
{
  public:
    SymTableException(std::string message, int line);
	  const char * what() const throw();
  private:
	  std::string message_;
    int line_;
};

#endif
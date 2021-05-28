#ifndef __SYN_TREE_EXCEPTION_H__
#define __SYN_TREE_EXCEPTION_H__
#include <exception>
#include <string>

class SynTreeException: public std::exception
{
  public:
    SynTreeException(std::string message);
	const char * what() const throw();
  private:
	  std::string message;
};

#endif
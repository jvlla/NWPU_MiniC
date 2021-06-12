#include <stdio.h>

int f(int x, int y, int z);

int main(void)
{
	int a,b;
	a = 1 
	b = 2;
	
	f(a, b);
	
	return 0;
}

int f(int x, int y, int z)
{
	return x + y + z;
}
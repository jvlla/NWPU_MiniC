#include <stdio.h>

int main(void)
{
	int i;
	int a[10];
	
	i = 10;
	while(i > 0)
	{
		a[i] = i;
		i--;
	}
	
	return 0;
}
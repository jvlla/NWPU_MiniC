#include <stdio.h>

int main(void)
{
	int i;
	int a[10];
	i = 10;
	while(i > 0)
	{
		a[i]=0;
		i--;
	}
	i=10;
	while(i > 0)
	{
		a[i]++;
		i--;
	}
	
	return 0;
}
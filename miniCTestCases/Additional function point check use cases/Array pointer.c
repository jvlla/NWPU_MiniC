int main() {
	int arr[5];
	int (*p1)[5];
	int flag;
	
	arr[0]=1;
	arr[1]=2;
	arr[2]=3;
	arr[3]=4;
	arr[4]=5;

	flag=0;
	p1 = &arr;
	if ((*p1)[4] == 5)
	{
		flag=0;
	}
	else {
		flag=-1;
	}
	return flag;
}
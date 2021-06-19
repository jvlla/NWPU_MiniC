
int main() {
	int arr[5];
	int* p[5];
	int i,flag;

	arr[0]=1;
	arr[1]=2;
	arr[2]=3;
	arr[3]=4;
	arr[4]=5;
	flag=0;
	i = 0;
	while (i < 5) {
		p[i] = &arr[i];
		i++;
	}
	
	if (*p[1] == 2) {
		flag=0;
	}
	else {
		flag=-1;
	}
	return flag;
}
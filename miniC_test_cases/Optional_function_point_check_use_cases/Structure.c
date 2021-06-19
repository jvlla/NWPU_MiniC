struct TEST{
	int a;
	int b;
};


int main() {
	struct TEST a;
	struct TEST b;
	a.a = 1;
	a.b = 2;
	b = a;
	return 0;
}
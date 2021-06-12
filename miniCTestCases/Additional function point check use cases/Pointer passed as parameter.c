
int add(int *a, int *b) {
	return *a + *b;
}
int main() {
	int a,b,c;
	a = 2;
	b = 3;
	c = add(&a, &b);
	return 0;
}
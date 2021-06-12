
int main() {
	int b;
	int* c;
	c = &b;
	*c = 456;
	b = 234;

	return 0;
}
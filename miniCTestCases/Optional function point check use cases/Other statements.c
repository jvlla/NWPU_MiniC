
int main() {
	int a,i,b,c;
	a = 10;
	b = 4;
	c = 6;
label:
	a--;
	for (i = 0; i < a; i++) {
		do {
			b--;
		} while (b < 0);
		if (i == 3) {
			goto label;
		}
	}
	switch (c) {
	case 6:c--;
	case 5:c--;
	case 4:c--;
	default:c = 15;
	}
	return 0;
}
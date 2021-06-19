int head(int a[2][2]) {
    return a[0][0];
}

int main()
{
    int a [2][2];
    int c;
    a[0][0] = 1;
    a[0][1] = 2;
    c = head(a);
    return 0;
}
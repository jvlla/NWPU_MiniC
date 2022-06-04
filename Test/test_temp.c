int add(int a, int b)
{
    int c, d[2];
    c = 1;
    d[1] = 2;
    if(c > 0)
    {
        c = c + d[1];
    }
    return c;
}

int main()
{
    int a, b;
    a= 5;
    b = 4;
    while (a > 0)
    {
        if (b > 0)
            b--;
        else
            ++b;
        if (b == 5)
            continue;
        if (a > 0)
            ;
        while (b > 5)
            break;
        a = add(a, -1);
    }
    return 0;
}


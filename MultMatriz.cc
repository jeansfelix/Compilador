int main()
{
    int a[3][4];
    int b[4][10];
    int c[3][10];
    int i, j, k, acumulador;
    
    for (i = 0; i < 3; i = i + 1) 
    {
        for (j = 0; j < 4; j = j + 1) 
        {
            a[i,j] = 1;
        }
    }
    
    for (i = 0; i < 4; i = i + 1) 
    {
        for (j = 0; j < 10; j = j + 1) 
        {
            b[i,j] = 1;
        }
    }
    
    acumulador = 0;
    
    for (i = 0; i < 3; i = i + 1) 
    {
        for (j = 0; j < 10; j = j + 1) 
        {
            for (k = 0; k < 4; k = k + 1) 
            {
                acumulador = acumulador + a[i,k] * b[k,j];
            }
            c[i,j] = acumulador;
            acumulador = 0;
        }
    }
    
    for (j = 0; j < 10; j = j + 1) 
    {
        for (i = 0; i < 3; i = i + 1) 
        {
            print(c[i,j] + " ");
        }
        print("\n");
    }
    
    
    return 0;
}


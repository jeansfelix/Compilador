int mdc(int a, int b )
{   
    if( b equal 0)
    {
        return a;
    }
    
    int temp;
    temp = a % b;
    
    return mdc(b, temp);
}

int main()
{   
    int mc; 
    int a, b;
    
    print("Calcular MDC(a,b):\n");
    print("Digite o valor de a:\n");
    scan(a);
    
    print("Digite o valor de b:\n");
    scan(b);
    
    mc = mdc(30, 36);
    
    print("O mdc entre " + a + " e " + b + " vale: "+ mc + "\n");
    
    return 0;
}


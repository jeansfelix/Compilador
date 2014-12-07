double discriminante(double a, double b, double c)
{
    return b*b - 4.0*a*c;
}

string calcularRaiz(double a, double b, double c)
{
    double b_dividido_2a, delta;
    double raiz1, raiz2;
    
    delta = discriminante(a,b,c);
    b_dividido_2a = - b / 2.0 * a;
    
    if (delta >= 0.0) 
    {
        raiz1 = b_dividido_2a + sqrt(delta) / 2.0*a;
        raiz2 = b_dividido_2a - sqrt(delta) / 2.0*a;
    
        return "raiz 1: " + raiz1 + "\nraiz 2: " + raiz2;
    }
    
    string r1, r2;
    delta = -delta;
    
    r1 = b_dividido_2a + " + i * " + sqrt(delta);
    r2 = b_dividido_2a + " - i * " + sqrt(delta);
    
    return "raiz 1: " + r1 + "\nraiz 2: " + r2;
}

int main()
{
    double a, b, c;
    string auxiliar;
    
    while (true) 
    {
        print("Entre com o coeficiente a de x²:\n");
        scan(a);
        
        print("Entre com o coeficiente b de x:\n");
        scan(b);
        
        print("Entre com o coeficiente c:\n");
        scan(c);
        
        auxiliar = calcularRaiz(a,b,c);
        
        print(auxiliar + "\n");
        
        print("Quer entrar como novos coeficientes?\n(Responda com sim ou nao e tecle enter)\n");
        scan(auxiliar);
        
        while ((auxiliar != "nao") and (auxiliar != "sim")) 
        {
            print("Responda somente com sim ou não e tecle enter\n");
            scan(auxiliar);
        }
        
        if (auxiliar == "nao") 
        {
            break;
        }
    }
    
    return 0;
}


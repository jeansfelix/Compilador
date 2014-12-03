/* Eu me amo. */

string b;

int main()
{
    int a;
    
    for (a = 0; a<4 ; a = a + 1)
    {
        print(a + "\n");
    }
    
    while (a<8) 
    {
        a = a+1;
        print(a + "\n");
    }
    
    do 
    {
        a = a+1;
        print(a + "\n");
        if ( a == 12) 
        {
            break;
        }
    } while (true);
    
    string c;
    
    b = "67_"+ 5 + "\n";
    
    c = b + a + " AQUI\n";
    
    print(c);
    
    return 0;
}



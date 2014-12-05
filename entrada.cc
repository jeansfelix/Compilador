int mdc(int a, int b ){
    if(b==0){
        return a;
    }
    int temp;
    temp = a % b;
    return mdc(temp, b);
}

int main(){   
    int mc; 
    mc = mdc(10, 5);
    return 0;
}
#include <iostream>
#include <ctime>
#include <cmath>
using namespace std;

double test(double x,double y){
double res;
asm(
    "fyl2x\n" //;Стек FPU теперь содержит: ST(0)=y*log2(x)
    "fld %%st(0)\n"          //Создаем еще одну копию z                      добавляем в стек
    "frndint\n"              //Округляем ST(0)=trunc(z) | ST(1)=z                
    "fxch %%st(1)\n"         //ST(0)=z | ST(1)=trunc(z)                      меняет местами содержимое регистров
    "fsub %%st(0),%%st(1)\n" //;ST(0)=z-trunc(z) | ST(1)=trunc(z)            вычесть st(1) из st(0)
    "f2xm1\n"                //ST(0)=2^(z-trunc(z))-1 | ST(1)=trunc(z)          2 в степени z
    "fld1\n"                 //ST(0)=1 ST(1)=2^(z-trunc(z))-1 | ST(2)=trunc(z)  загружает константу 1 в стек      
    "faddp %%st(1),%%st\n"   //ST(0)=2^(z-trunc(z)) | ST(1)=trunc(z)         сложение с извлечением из стека
    "fscale\n"               //ST(0)=(2^(z-trunc(z)))*(2^trunc(z))=2^(z)     умножает ST на 2 в степени ST(1) и помещает результат в ST
    "fstp %%st(0)"           //                                              сохранить вещественное число с извлечением из стека
    "fistp res\n"
    : "=t"(res)                 //ограничитель t:Первый регистр (вершина стека) плавающей точки.
    : "0" (y), "u" (x) 
    :"st(1)"
);
    return res;
}

int main(){
    double exponent = 3.5, base=2.5, res;
    cout<<base<<" in "<<exponent<<":\n";
    cout<<"Expected result= "<<(exponent*log(base)/log(2))<<endl;
    int start_time = clock();
    res = test(base,exponent);
    int end_time = clock();
    cout<<"Actual result =  "<<res<<endl;
    cout<<"Time execute="<<end_time - start_time<<endl;
    return 0;
}

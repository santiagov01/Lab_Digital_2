#include <iostream>

using namespace std;
int main()
{
    int vector2[] = {2,7,10,4,9,6};
    int data[12] = {0,1,1,2,3,5,8,13,21,34,55,89};
    int N = sizeof(vector2)/ sizeof(vector2[0]); //TAMAÑO (aunque ya es dado por usuario)
    int sorted_values[N];//Crear lista
    int ORD = 1; //Orden de valores. 0 Ascendete. 1 Descendente
    
    
//-------------------------------------------------------------------
// ORDENAR LISTA DE TERMINOS SOLICITADOS
//-------------------------------------------------------------
    for(int i = 0; i < N-1; i++){
        for(int j = 0; j < N-i-1; j++){
            //ORDENAR ASCENDENTE
            if (ORD == 0 && vector2[j] > vector2[j + 1]) {//Reviso cada item de la lista
            int temp = vector2[j];//temporal
            vector2[j] = vector2[j + 1]; // intercambio
            vector2[j + 1] = temp;
        //ORDENAR DESCENDENTE
          } else if (ORD == 1 && vector2[j] < vector2[j + 1]) {//Reviso cada item de la lista
            int temp = vector2[j];//temporal
            vector2[j] = vector2[j + 1]; // intercambio
            vector2[j + 1] = temp;
          }
        }
    }


    cout << "Valores solicitados ordenados ordenados\n";
    for(int k = 0; k < N; k++){
        cout << vector2[k] << " ";
    }
    cout << "\nTerminos de la serie de acuerdo a su posicion\n";
    
//--------------------------------------------------------------
// RECORRER SERIE DE FIBBONIACCI DE ACUERDO A LAS POSICIONES SOLICITADAS (GUARDAR EN MEMORIA)
// -------------------------------------------------------------
    for(int u = 0; u < N; u++){
        int index = vector2[u]; //Extraigo la posición solicitada de la lista previamente ordenada
        int data_out_aux = data[index-1]; //Extraigo el valor de la serie y lo guardo en una variable
        sorted_values[u] = data_out_aux; //Almaceno el valor en la memoria
        cout << data_out_aux << " ";
        }     

    return 0;
}


/*
 * Programa desarrollado por:
 * Juan Martin Loyola
 * Universidad Nacional de San Luis
 * 2015
*/

// Programa en C que se encarga de 'limpiar' uno de los dataset R8, ya que cada documento de este dataset termina con un espacio en blanco.

#include <stdio.h>
#include <string.h>

int main(int argc, char** argv){
	char nombreDatasetEntrada[35] = "";
	char nombreDatasetFinal[35] = "";

	// Controlo que la cantidad de argumentos con la que se llama el programa sea la correcta.
	// Si no es asi el programa muestra un mensaje indicando error y cierra.
	if (argc == 3){
		strcpy(nombreDatasetEntrada, argv[1]);
		strcpy(nombreDatasetFinal, argv[2]);
	}
	else{
		if (argc == 2){
			char cadenaAyuda[35] = "";
			strcpy(cadenaAyuda, argv[1]);
			if (strcmp(cadenaAyuda, "--help") == 0){
				printf("-----------------------------------------------------------------------\n");
				printf("Modo de empleo: \"%s nombreDatasetEntrada nombreDatasetFinal\".\n", argv[0]);
				printf("-----------------------------------------------------------------------\n");
				printf("Programa en C que se encarga de 'limpiar' uno de los dataset R8, ya que cada documento de este dataset termina con un espacio en blanco.\n");
				return 1;
			}
			else{
				printf("ERROR >> El programa \"%s\" requiere de dos argumentos.\n", argv[0]);
				printf("Intente \"%s --help\" para mas informacion\n", argv[0]);
				return 1;
			}
		}
		else{
			printf("ERROR >> El programa \"%s\" requiere de dos argumentos.\n", argv[0]);
			printf("Intente \"%s --help\" para mas informacion\n", argv[0]);
			return 1;
		}
	}

	printf("Comenzando programa...\n");


	// Abro el archivo donde se encuentra el dataset a leer.
	// En caso de no poder abrirlo se muestra un mensaje de error y cierra el programa.
	printf("Abriendo archivo para lectura... ");
	FILE *punteroDataset = NULL;
	punteroDataset = fopen(nombreDatasetEntrada, "r");
	
	if (punteroDataset == NULL){
		printf("\n");
		printf("ERROR >> No se pudo abrir el archivo \"%s\" para lectura.\n", nombreDatasetEntrada);
		return 1;
	}
	else
		printf("[OK]\n");

	// Abro el archivo para escritura.
	// En caso de no poder abrirlo se muestra un mensaje de error y se cierra el programa.
	printf("Abriendo archivo para escritura... ");
	FILE *punteroSalida = NULL;	
	punteroSalida = fopen(nombreDatasetFinal, "w");

	if (punteroSalida == NULL){
		printf("\n");
		printf("ERROR >> No se pudo crear el archivo \"%s\" para escritura.\n", nombreDatasetFinal);
		return 1;
	}
	else
		printf("[OK]\n");

	// Comienzo a leer el documento linea por linea y limpiando las lineas del dataset.
	char contenidoLinea[50000] = "";
	char contenidoLineaLimpia[50000] = "";

	// Comienzo leyendo una linea del dataset. Cuando llegamos al final del arhivo tendremos EOF, asi la funcion fgets retornara NULL y podremos continuar a la ultima parte del programa (cerrar los punteros de los archivos).
	printf("Comienzo a 'limpiar' el dataset...\n");
	while(fgets(contenidoLinea, sizeof(contenidoLinea)-1, punteroDataset) != NULL){ // Notar que leo sizeof(contenidoLinea) - 1 caracteres para dejar lugar para el caracter '\0'.
		// La funcion strncpy nos permite copiar una porcion del string. La cantidad copiada es determinada por el tercer argumento de la funcion. En este caso el valor es strlen(contenidoLinea) - 2 que nos retorna la longitud del string fuente menos dos. Notar que aqui se resta dos para no considerar el caracter '\n' final y el caracter ' ' antes de este.
		strncpy(contenidoLineaLimpia, contenidoLinea, strlen(contenidoLinea)-2);
		// Luego de limpiado debo agregar el caracter '\n' nuevamente y cerrar el string con el caracter '\0'.
		contenidoLineaLimpia[strlen(contenidoLinea)-2] = '\n';
		contenidoLineaLimpia[strlen(contenidoLinea)-1] = '\0';
		// Copio el contenido del documento limpio al archivo.
		fputs(contenidoLineaLimpia, punteroSalida);
	}
	fclose(punteroSalida);
	fclose(punteroDataset);

	printf("\rEl programa finalizo correctamente.\n");

	return 0;
}

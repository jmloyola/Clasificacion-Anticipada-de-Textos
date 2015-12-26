/*
 * Programa desarrollado por:
 * Juan Martin Loyola
 * Universidad Nacional de San Luis
 * 2015
*/

/* 
 * Programa en C que se encarga de generar una estructura de directorios con los documentos en archivos individuales
 * y dentro de carpetas cuyo nombre es la clase del documento particular.
 *
 * Tener en cuenta que este programa es utilizado para trabajar con datasets con las siguientes caracteristicas:
 * 		> Todos los documentos se encuentran en un unico archivo separados por el caracter nueva linea.
 *		> Cada linea del archivo contiene: la clase del documento, un caracter tab, el contenido del documento y en caracter de nueva linea.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char** argv){
	char nombreDocumentos[35] = "";
	char nombreCarpetaFinal[35] = "";

	// Controlo que la cantidad de argumentos con la que se llama el programa sea la correcta.
	// Si no es asi el programa muestra un mensaje indicando error y cierra.
	if (argc == 3){
		strcpy(nombreDocumentos, argv[1]);
		strcpy(nombreCarpetaFinal, argv[2]);
	}
	else{
		if (argc == 2){
			char cadenaAyuda[35] = "";
			strcpy(cadenaAyuda, argv[1]);
			if (strcmp(cadenaAyuda, "--help") == 0){
				printf("-----------------------------------------------------------------------\n");
				printf("Modo de empleo: \"%s DataSetFile NombreDirectorioFinal\".\n", argv[0]);
				printf("-----------------------------------------------------------------------\n");
				printf("Programa en C que se encarga de generar una estructura de directorios con los documentos en archivos individuales y dentro de carpetas cuyo nombre es la clase del documento particular.\n\n");
				printf("Tener en cuenta que este programa es utilizado para trabajar con datasets con las siguientes caracteristicas:\n");
				printf("\t> Todos los documentos se encuentran en un unico archivo separados por el caracter nueva linea.\n");
				printf("\t> Cada linea del archivo contiene: la clase del documento, un caracter tab, el contenido del documento y en caracter de nueva linea.\n ");
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


	// Abro el archivo donde se encuentran los documentos para leer.
	// En caso de no poder abrirlo se muestra un mensaje de error y cierra el programa.
	printf("Abriendo archivo para lectura... ");
	FILE *punteroDocumentos = NULL;
	punteroDocumentos = fopen(nombreDocumentos, "r");
	
	if (punteroDocumentos == NULL){
		printf("\n");
		printf("ERROR >> No se pudo abrir el archivo \"%s\" para lectura.\n", nombreDocumentos);
		return 1;
	}
	else
		printf("[OK]\n");

	// Obtengo el directorio actual en el que se esta ejecutando el programa.
	char directorioBase[1024] = "";
	if (getcwd(directorioBase, sizeof(directorioBase)) == NULL){
		printf("ERROR >> No se pudo obtener el directorio actual.\n");
		return 1;
	}

	// Formo el path al directorio final.
	char directorioFinal[1024] = "";
	strcat(directorioFinal, directorioBase);
	strcat(directorioFinal, "/");
	strcat(directorioFinal, nombreCarpetaFinal);
	strcat(directorioFinal, "/");

	// Controlo si el directorio final ya existe o no. Si no existe lo creo. Si existe muestro una advertencia indicando que elimine o use otro nombre de directorio final y cierro el programa.
	printf("Controlo si el directorio final ya existe...\n");
	struct stat estadisticaDirectorioFinal = {0};
	if (stat(directorioFinal, &estadisticaDirectorioFinal) == -1) {
		printf("Creando directorio final... ");
		mkdir(directorioFinal, 0700);
		printf("[OK]\n");
	}
	else{
		printf("WARNING >> El directorio \"%s\" ya existe. Elimine el directorio o use otro nombre de directorio para evitar conflictos.\n", directorioFinal);
		return 1;
	}


	// Comienzo a leer el documento linea por linea y generando los archivos en las carpetas que corresponde.
	char claseDocumento[50] = "";
	char contenidoDocumento[50000] = "";
	int contadorDocumentos = 1;


	// Comienzo leyendo la clase del documento y guardandola en claseDocumento. Cuando lleguemos al final del arhivo tendremos EOF y podemos continuar a la finalizacion del programa.
	printf("Comienzo a generar el dataset...\n");
	while(fscanf(punteroDocumentos, "%s\t", claseDocumento) != EOF){
		// Progress Bar...
		int i;
		printf("[");
		for (i = 0; i < (contadorDocumentos % 78); i++){
			printf("-");
		}
		for (i=0; i < (78 - (contadorDocumentos % 78)); i++){
			printf(" ");
		}
		printf("]\r");


		// Leo el documento completo y lo almaceno en contenidoDocumento.
		fgets(contenidoDocumento, sizeof(contenidoDocumento)-1, punteroDocumentos);
		
		// Controlo si el directorio con el nombre de la clase del documento existe o no. Si no existe lo crea.
		struct stat estadisticaDirectorio = {0};
		char nombreDirectorio[1024] = "";

		strcat(nombreDirectorio, directorioFinal);
		strcat(nombreDirectorio, claseDocumento);
		strcat(nombreDirectorio, "/");
		if (stat(nombreDirectorio, &estadisticaDirectorio) == -1) {
			mkdir(nombreDirectorio, 0700);
		}
	
		// Genero el nombre del archivo cuyo contenido sera el documento.
		char nombreSalida[1024] = "";
		char stringContadorDocumentos[7] = "";

		sprintf(stringContadorDocumentos, "%d", contadorDocumentos); // Funcion utilizada para convertir un entero en string.
		strcat(nombreSalida, nombreDirectorio);
		strcat(nombreSalida, stringContadorDocumentos);
		strcat(nombreSalida, ".txt");

		// Abro el archivo para escritura.
		// En caso de no poder abrirlo se muestra un mensaje de error y se cierra el programa.
		FILE *punteroSalida = NULL;	
		punteroSalida = fopen(nombreSalida, "w");
	
		if (punteroSalida == NULL){
			printf("ERROR >> No se pudo crear el archivo \"%s\" para escritura.\n", nombreSalida);
			return 1;
		}

		// Copio el contenido del documento al archivo.
		fputs(contenidoDocumento, punteroSalida);
	
		contadorDocumentos++;
		fclose(punteroSalida);
	}

	// Limpiando el progress bar
	int i;
	for (i = 0; i < 80; i++){
		printf(" ");
	}
	printf("\rEl programa finalizo correctamente.\n");

	fclose(punteroDocumentos);

	return 0;
}

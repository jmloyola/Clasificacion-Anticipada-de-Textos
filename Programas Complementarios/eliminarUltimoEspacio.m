clear all; close all; clc;

% Obtengo el directorio actual sobre el que se esta corriendo el script.
directorioActual = pwd;

datasets{1} = 'r8-test-no-short.txt';
datasets{2} = 'r8-test-no-stop.txt';
datasets{3} = 'r8-train-no-short.txt';
datasets{4} = 'r8-train-no-stop.txt';
datasets{5} = 'r52-test-all-terms.txt';
datasets{6} = 'r52-test-no-short.txt';
datasets{7} = 'r52-test-no-stop.txt';
datasets{8} = 'r52-train-all-terms.txt';
datasets{9} = 'r52-train-no-short.txt';
datasets{10} = 'r52-train-no-stop.txt';

for i= 1:length(datasets)
    pathCompletoADataset = [directorioActual '\' datasets{i}];
    identificadorEnteroDataset = fopen(pathCompletoADataset);
    
    %% Leo el dataset linea por linea borrando el espacio que se encuentra al final de cada documento.
    lineaDataset = fgetl(identificadorEnteroDataset);
    indice = 1;
    while ischar(lineaDataset)
        datasetEntero{indice} = lineaDataset(1:(end-1));
        
        lineaDataset = fgetl(identificadorEnteroDataset);
        indice = indice + 1;
    end
    clear lineaDataset;
    fclose(identificadorEnteroDataset);
    
    indicePunto = strfind(pathCompletoADataset, '.');
    nombreArchivoSalida = [pathCompletoADataset(1:(indicePunto-1)) '-clean' pathCompletoADataset(indicePunto:end)];
    identificadorEnteroDataset = fopen(nombreArchivoSalida, 'w');
    
    CaracterFinLinea = [char(13) char(10)];
    for k=1:length(datasetEntero)
         fwrite(identificadorEnteroDataset, [datasetEntero{k} CaracterFinLinea], 'uchar'); 
    end
    fclose(identificadorEnteroDataset);
    
    clear datasetEntero;
end

disp('El programa finalizo exitosamente');

clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;
directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset];
cd(directorioVariablesWorkspace);

nombreMatrices = [nombreDataset '_Matrices.mat'];

load(nombreMatrices, 'Ytrain', 'seqinf');

cantidadClases = length(unique(Ytrain));
for i= 1:cantidadClases
    documentosClaseI = find(Ytrain==i);
    serieDeTerminosPorClaseDataset = [];
    for j= 1:length(documentosClaseI)
        nuevoDocumento = full(seqinf(documentosClaseI(j),:));
        serieDeTerminosPorClaseDataset = [serieDeTerminosPorClaseDataset nuevoDocumento(find(nuevoDocumento))];
    end
    
    dicPorClase{i} = unique(serieDeTerminosPorClaseDataset);
    
    cantRepeticionTerminos = accumarray(serieDeTerminosPorClaseDataset', 1); % Con esta funcion (accumarray) podemos contar la cantidad de veces que se repite cada termino.
    %indicesCantRepeticionTerminos = find(cantRepeticionTerminos); % Al cuete.
    [valores, indicesValores] = sort(cantRepeticionTerminos);
    indicesTerminosMasFrecPorClase{i} = indicesValores(end-24 : end);
end

nombreterminosPorClase = [nombreDataset '_TerminosPorClase.mat'];

save(nombreterminosPorClase, 'indicesTerminosMasFrecPorClase', 'dicPorClase');

cd(directorioActual);

disp('El programa finalizo exitosamente');

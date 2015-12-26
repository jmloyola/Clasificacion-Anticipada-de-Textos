%{
 * Script desarrollado por:
 * Juan Martin Loyola
 * Universidad Nacional de San Luis
 * 2015
%}

%{
 * Script en matlab utilizado para obtener informacion de los distintos
 dataset.
 * Todas las variables interesantes son almacenadas en archivos .mat para
 luego utilizarlos para hacer las graficas.
%}

%% Antes de comenzar con el script, elimino todas las variables del workspace, cierro todas las figuras y limpio la consola.
% Elimino todas las variables en el workspace.
clear all; 
% Elimino todas las figuras.
close all;
% Clear Command Window.
clc;


%% Elijo sobre que dataset trabajar.
% nombreDataset = 'webkb-train-stemmed.txt';
% nombreDataset = 'webkb-test-stemmed.txt';
% nombreDataset = 'r8-test-all-terms-clean.txt';
% nombreDataset = 'r8-train-all-terms-clean.txt';
% nombreDataset = '20ng-train-stemmed.txt';
% nombreDataset = '20ng-test-stemmed.txt';
nombreDataset = 'test.txt';

%% Obtengo informacion para ubicar el dataset y abro el archivo donde se encuentra el dataset.
% Obtengo el directorio actual sobre el que se esta corriendo el script.
directorioActual = pwd;

indicePuntoNombreDataset = strfind(nombreDataset, '.');
pathCompletoADataset = [directorioActual '\Datasets\'  nombreDataset]; % Esto permite concatenar las cadenas.

identificadorEnteroDataset = fopen(pathCompletoADataset);


%% Leo el dataset linea por linea obteniendo la clase y el contenido de todos los documentos.
lineaDataset = fgetl(identificadorEnteroDataset);
indice = 1;
while ischar(lineaDataset)
    posicionTab = strfind(lineaDataset, sprintf('\t')); % Notar que se debe usar la funcion sprintf() ya que colocar la funcion strfind() con el string '\t' no tiene el efecto que deseamos. Este ultimo es un string con dos caracteres '\' y 't'.
    claseDocumento = lineaDataset(1:(posicionTab - 1));
    documento = lineaDataset((posicionTab + 1):end);

    clasesDocumentos{indice} = claseDocumento;
    documentos{indice} = documento;
    
    lineaDataset = fgetl(identificadorEnteroDataset);
    indice = indice + 1;
end

clear lineaDataset;
fclose(identificadorEnteroDataset);



%% Obtengo las distintas clases que existen en el dataset. Ademas para cada clase, obtengo el indice de los documentos de dicha clase en el dataset. Ademas, obtengo la cantidad de documentos que tiene cada clase.
uniqueClases = unique(clasesDocumentos);
indecesClaseEnDataset = cell(1, length(uniqueClases));
cantidadCadaClase = zeros(length(uniqueClases));

for i = 1:length(uniqueClases)
    % la funcion strcmp() compara cada string de la cell clasesDocumentos con
    % el string uniqueClases(i), devolviendo un arreglo con unos en las
    % posiciones que son iguales y cero en el resto.
    % Luego, la funcion find() retorna las posiciones de dicho arreglo que no
    % son cero.
    indecesClaseEnDataset{i} = find(strcmp(clasesDocumentos, uniqueClases(i)));
    % La funcion numel() retorna la cantidad de elementos de un arreglo.
    cantidadCadaClase(i) = numel(indecesClaseEnDataset{i});
end


%% Obtengo la clase de cada documento (igual que en la variable clasesDocumentos), solo que aqui la clase no es representada por el string sino que por un entero.
clasesDiscretizadas = zeros(length(clasesDocumentos),1);
for i = 1:length(clasesDocumentos)
    % La funcion ismember() retorna dos enteros: el entero 'a' indica si 
    % clasesDocumentos{i} se encuentra en uniqueClases. (Notar que el
    % entero 'a' siempre vale uno en esta iteracion ya que las clases de
    % los documentos siempre pertenecen a uniqueClases).
    % El entero 'b' indica (si el entero 'a' es uno) en que posicion de
    % uniqueClases se encuentra clasesDocumentos{i}. Si 'a' es cero 'b'
    % tambien.
    [a,b] = ismember(clasesDocumentos{i}, uniqueClases);
    clasesDiscretizadas(i) = b;
end


%% Creo el directorio donde almacenar las variables y guardo algunas interesantes en archivos con formato '.mat'. Luego elimino las variables para ahorrar espacio.
directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset(1:indicePuntoNombreDataset-1)];
% Controlo si existe el directorio. Si no existe creo la carpeta.
if (exist(directorioVariablesWorkspace, 'dir') ~= 7)
    mkdir(directorioVariablesWorkspace);
end
cd(directorioVariablesWorkspace);

nombreMatricesDataset = ['matrices_' nombreDataset(1:indicePuntoNombreDataset-1) '.mat'];
save(nombreMatricesDataset,'clasesDocumentos', 'clasesDiscretizadas', 'uniqueClases');
clear clasesDocumentos;


%% Obtengo dos diccionarios con los terminos usados en el dataset. Un diccionario completo, que tiene todas las palabras (sin restriccion). Y otro diccionario que contiene aquellas palabras que tengan 3 o mas caracteres.
cantidadTerminosDiccionarioCompleto = 0;
cantidadTerminosDiccionario = 0;
cantidadTerminosDataset = 0;
cantidadTerminosDatasetReducido = 0;
numeroPalabrasPorDocumento = zeros(length(documentos), 1);
numeroPalabrasPorDocumentoReducido = zeros(length(documentos), 1);

for i = 1:length(documentos)
    indicesEspacioBlanco = strfind(documentos{i}, ' ');
    
    for j = 1:length(indicesEspacioBlanco)
        if (j == 1)
            termino = documentos{i}(1:(indicesEspacioBlanco(j)-1));
        else
            termino = documentos{i}((indicesEspacioBlanco(j-1)+1):(indicesEspacioBlanco(j)-1));
        end
        
        cantidadTerminosDataset = cantidadTerminosDataset + 1;
        numeroPalabrasPorDocumento(i) = numeroPalabrasPorDocumento(i) + 1;
        if (length(termino) > 2)
            cantidadTerminosDatasetReducido = cantidadTerminosDatasetReducido + 1;
            numeroPalabrasPorDocumentoReducido(i) = numeroPalabrasPorDocumentoReducido(i) + 1;
        end
        
        if (cantidadTerminosDiccionarioCompleto == 0) % Notar que si el diccionario completo no tienen terminos significa que el otro diciconario tampoco tendra terminos. OJO. No significa que dicho termino deba estar en el diccionario reducido (si no tiene mas de 2 caracteres no pertenece).
            cantidadTerminosDiccionarioCompleto = cantidadTerminosDiccionarioCompleto + 1;
            diccionarioCompleto{cantidadTerminosDiccionarioCompleto} = termino;
            
            if (length(termino) > 2)
                cantidadTerminosDiccionario = cantidadTerminosDiccionario + 1;            
                diccionario{cantidadTerminosDiccionario} = termino;
            end
        else
            pertenece = ismember(termino, diccionarioCompleto);
            if (~pertenece)
                cantidadTerminosDiccionarioCompleto = cantidadTerminosDiccionarioCompleto + 1;
                diccionarioCompleto{cantidadTerminosDiccionarioCompleto} = termino;
                if (length(termino) > 2)
                    cantidadTerminosDiccionario = cantidadTerminosDiccionario + 1;
                    diccionario{cantidadTerminosDiccionario} = termino;
                end
            end
        end
    end
    if (~isempty(indicesEspacioBlanco))
        termino = documentos{i}((indicesEspacioBlanco(end)+1):end);
        
        cantidadTerminosDataset = cantidadTerminosDataset + 1;
        numeroPalabrasPorDocumento(i) = numeroPalabrasPorDocumento(i) + 1;
        if (length(termino) > 2)
            cantidadTerminosDatasetReducido = cantidadTerminosDatasetReducido + 1;
            numeroPalabrasPorDocumentoReducido(i) = numeroPalabrasPorDocumentoReducido(i) + 1;
        end

        if (cantidadTerminosDiccionarioCompleto == 0)
            cantidadTerminosDiccionarioCompleto = cantidadTerminosDiccionarioCompleto + 1;            
            diccionarioCompleto{cantidadTerminosDiccionarioCompleto} = termino;
            if (length(termino) > 2)
                cantidadTerminosDiccionario = cantidadTerminosDiccionario + 1;
                diccionario{cantidadTerminosDiccionario} = termino;
            end
        else
            pertenece = ismember(termino, diccionarioCompleto);
            if (~pertenece)
                cantidadTerminosDiccionarioCompleto = cantidadTerminosDiccionarioCompleto + 1;
                diccionarioCompleto{cantidadTerminosDiccionarioCompleto} = termino;
                if (length(termino) > 2)
                    cantidadTerminosDiccionario = cantidadTerminosDiccionario + 1;
                    diccionario{cantidadTerminosDiccionario} = termino;
                end
            end
        end
    else
        % Significa que el documento no tiene terminos o tiene un unico
        % termino.
        if (~isempty(documentos{i}))
            termino = documentos{i}(1:end);
            
            cantidadTerminosDataset = cantidadTerminosDataset + 1;
            numeroPalabrasPorDocumento(i) = numeroPalabrasPorDocumento(i) + 1;
            if (length(termino) > 2)
                cantidadTerminosDatasetReducido = cantidadTerminosDatasetReducido + 1;
                numeroPalabrasPorDocumentoReducido(i) = numeroPalabrasPorDocumentoReducido(i) + 1;
            end
            
            if (cantidadTerminosDiccionarioCompleto == 0)
                cantidadTerminosDiccionarioCompleto = cantidadTerminosDiccionarioCompleto + 1;                
                diccionarioCompleto{cantidadTerminosDiccionarioCompleto} = termino;
                if (length(termino) > 2)
                    cantidadTerminosDiccionario = cantidadTerminosDiccionario + 1;
                    diccionario{cantidadTerminosDiccionario} = termino;                    
                end                               
            else
                pertenece = ismember(termino, diccionarioCompleto);
                if (~pertenece)
                    cantidadTerminosDiccionarioCompleto = cantidadTerminosDiccionarioCompleto + 1;
                    diccionarioCompleto{cantidadTerminosDiccionarioCompleto} = termino;
                    if (length(termino) > 2)
                        cantidadTerminosDiccionario = cantidadTerminosDiccionario + 1;
                        diccionario{cantidadTerminosDiccionario} = termino;
                    end
                end
            end
            
        end   
    end
end


%% Ordeno los diccionario alfabeticamente.
% Notar que se debio hacer una transposicion de las matrices para poder
% usar la funcion sortrows(), ya que esta funcion ordena filas basandose en
% el valor de sus columnas de la misma forma que se hace en un diccionario.
diccionarioCompletoOrdenado = sortrows(diccionarioCompleto');
diccionarioOrdenado = sortrows(diccionario');


%% Obtengo dos matrices sparse con los terminos por documento. En una de las matrices se usa el diccionario reducido y en la otra el diccionario completo. Almacenamos por cada documento la cantidad de veces que ocurre cada termino en dicho  documento. Notar que las columnas de las matrices se corresponden con los documentos y las filas con los terminos
% Utilizo las variables filas, columnas y valores para poder generar luego
% la matriz sparse a partir de ellas.
% Con estas puedo formar la tri-upla (x,y)=z donde 'x' es la posicion en la
% fila, 'y' es la posicion en la columna y 'z' es el valor de dicha
% posicion.
% Notar que el valor siempre es 1 (uno) aqui. Esto se debe a que luego al
% generar la matriz se suman todos los valores para cada posicion
% determinada (x,y).
filasDatasetCompleto = zeros(1, cantidadTerminosDataset);
columnasDatasetCompleto = zeros(1, cantidadTerminosDataset);
valoresDatasetCompleto = zeros(1, cantidadTerminosDataset);

filasDatasetReducido = zeros(1, cantidadTerminosDatasetReducido);
columnasDatasetReducido = zeros(1, cantidadTerminosDatasetReducido);
valoresDatasetReducido = zeros(1, cantidadTerminosDatasetReducido);

serieDeTerminosDataset = zeros(1, cantidadTerminosDataset);
serieDeTerminosDatasetReducido = zeros(1, cantidadTerminosDatasetReducido);


% Notar que no reservo lugar previamente para las variables
% serieDeTerminosPorClaseDataset y serieDeTerminosPorClaseDatasetReducido
% ya que no se la cantidad de terminos que tendran estos.
indicesSeriesPorClaseDataset = zeros(1, length(uniqueClases));
indicesSeriesPorClaseDatasetReducido = zeros(1, length(uniqueClases));

cantidadTerminosDataset = 0;
cantidadTerminosDatasetReducido = 0;

indiceSparseMatrixDatasetCompleto = 0;
indiceSparseMatrixDatasetReducido = 0;

for i = 1:length(documentos)
    claseDocumentoActual = clasesDiscretizadas(i);
    indicesEspacioBlanco = strfind(documentos{i}, ' ');

    for j = 1:length(indicesEspacioBlanco)
        if (j == 1)
            termino = documentos{i}(1:(indicesEspacioBlanco(j)-1));
        else
            termino = documentos{i}((indicesEspacioBlanco(j-1)+1):(indicesEspacioBlanco(j)-1));
        end
        % Determino si el termino actual se encuentra en el 
        % diccionarioCompletoOrdenado, y si es asi determino en que
        % posicion se encuentra.
        [~,b] = ismember(termino, diccionarioCompletoOrdenado);
        cantidadTerminosDataset = cantidadTerminosDataset + 1;
        serieDeTerminosDataset(cantidadTerminosDataset) = b;
        
        indicesSeriesPorClaseDataset(claseDocumentoActual) = indicesSeriesPorClaseDataset(claseDocumentoActual) + 1;     
        serieDeTerminosPorClaseDataset(claseDocumentoActual, indicesSeriesPorClaseDataset(claseDocumentoActual)) = b;
        
        
        indiceSparseMatrixDatasetCompleto = indiceSparseMatrixDatasetCompleto + 1;
        filasDatasetCompleto(indiceSparseMatrixDatasetCompleto) = b;
        columnasDatasetCompleto(indiceSparseMatrixDatasetCompleto) = i;
        valoresDatasetCompleto(indiceSparseMatrixDatasetCompleto) = 1;
        
        % Determino si el termino actual se encuentra en el 
        % diccionarioOrdenado, y si es asi determino en que
        % posicion se encuentra.
        [a,b] = ismember(termino, diccionarioOrdenado);
        if (a==1)            
            cantidadTerminosDatasetReducido = cantidadTerminosDatasetReducido + 1;
            serieDeTerminosDatasetReducido(cantidadTerminosDatasetReducido) = b;
            
            indicesSeriesPorClaseDatasetReducido(claseDocumentoActual) = indicesSeriesPorClaseDatasetReducido(claseDocumentoActual) + 1;
            serieDeTerminosPorClaseDatasetReducido(claseDocumentoActual, indicesSeriesPorClaseDatasetReducido(claseDocumentoActual)) = b;
            
            indiceSparseMatrixDatasetReducido = indiceSparseMatrixDatasetReducido + 1;
            filasDatasetReducido(indiceSparseMatrixDatasetReducido) = b;
            columnasDatasetReducido(indiceSparseMatrixDatasetReducido) = i;
            valoresDatasetReducido(indiceSparseMatrixDatasetReducido) = 1;
        end
    end
    if (~isempty(indicesEspacioBlanco))
        termino = documentos{i}((indicesEspacioBlanco(end)+1):end);
        [~,b] = ismember(termino, diccionarioCompletoOrdenado);
        cantidadTerminosDataset = cantidadTerminosDataset + 1;
        serieDeTerminosDataset(cantidadTerminosDataset) = b;
        
        indicesSeriesPorClaseDataset(claseDocumentoActual) = indicesSeriesPorClaseDataset(claseDocumentoActual) + 1;
        serieDeTerminosPorClaseDataset(claseDocumentoActual, indicesSeriesPorClaseDataset(claseDocumentoActual)) = b;
        
        indiceSparseMatrixDatasetCompleto = indiceSparseMatrixDatasetCompleto + 1;
        filasDatasetCompleto(indiceSparseMatrixDatasetCompleto) = b;
        columnasDatasetCompleto(indiceSparseMatrixDatasetCompleto) = i;
        valoresDatasetCompleto(indiceSparseMatrixDatasetCompleto) = 1;

        [a,b] = ismember(termino, diccionarioOrdenado);
        if (a==1)
            cantidadTerminosDatasetReducido = cantidadTerminosDatasetReducido + 1;
            serieDeTerminosDatasetReducido(cantidadTerminosDatasetReducido) = b;
            
            indicesSeriesPorClaseDatasetReducido(claseDocumentoActual) = indicesSeriesPorClaseDatasetReducido(claseDocumentoActual) + 1;
            serieDeTerminosPorClaseDatasetReducido(claseDocumentoActual, indicesSeriesPorClaseDatasetReducido(claseDocumentoActual)) = b;
            
            indiceSparseMatrixDatasetReducido = indiceSparseMatrixDatasetReducido + 1;
            filasDatasetReducido(indiceSparseMatrixDatasetReducido) = b;
            columnasDatasetReducido(indiceSparseMatrixDatasetReducido) = i;
            valoresDatasetReducido(indiceSparseMatrixDatasetReducido) = 1;
        end
    else
        % Significa que el documento no tiene terminos o tiene un unico
        % termino.
        if (~isempty(documentos{i}))
            termino = documentos{i}(1:end);
            
            [~,b] = ismember(termino, diccionarioCompletoOrdenado);
            cantidadTerminosDataset = cantidadTerminosDataset + 1;
            serieDeTerminosDataset(cantidadTerminosDataset) = b;
            
            indicesSeriesPorClaseDataset(claseDocumentoActual) = indicesSeriesPorClaseDataset(claseDocumentoActual) + 1;
            serieDeTerminosPorClaseDataset(claseDocumentoActual, indicesSeriesPorClaseDataset(claseDocumentoActual)) = b;

            indiceSparseMatrixDatasetCompleto = indiceSparseMatrixDatasetCompleto + 1;
            filasDatasetCompleto(indiceSparseMatrixDatasetCompleto) = b;
            columnasDatasetCompleto(indiceSparseMatrixDatasetCompleto) = i;
            valoresDatasetCompleto(indiceSparseMatrixDatasetCompleto) = 1;

            [a,b] = ismember(termino, diccionarioOrdenado);
            if (a==1)        
                cantidadTerminosDatasetReducido = cantidadTerminosDatasetReducido + 1;
                serieDeTerminosDatasetReducido(cantidadTerminosDatasetReducido) = b;
                
                indicesSeriesPorClaseDatasetReducido(claseDocumentoActual) = indicesSeriesPorClaseDatasetReducido(claseDocumentoActual) + 1;
                serieDeTerminosPorClaseDatasetReducido(claseDocumentoActual, indicesSeriesPorClaseDatasetReducido(claseDocumentoActual)) = b;

                indiceSparseMatrixDatasetReducido = indiceSparseMatrixDatasetReducido + 1;
                filasDatasetReducido(indiceSparseMatrixDatasetReducido) = b;
                columnasDatasetReducido(indiceSparseMatrixDatasetReducido) = i;
                valoresDatasetReducido(indiceSparseMatrixDatasetReducido) = 1;
            end
            
        end           
    end
end

% Creo las matrices sparse con las variables 'filas', 'columnas' y
% 'valores'.
terminosDoucmentoSparseMatrixDatasetCompleto = sparse(filasDatasetCompleto, columnasDatasetCompleto, valoresDatasetCompleto);
terminosDoucmentoSparseMatrixDatasetReducido = sparse(filasDatasetReducido, columnasDatasetReducido, valoresDatasetReducido);


%% Guardo otras variables interesantes.
nombreDiccionariosSalida = ['diccionarios_' nombreDataset(1:indicePuntoNombreDataset-1) '.mat'];
save(nombreDiccionariosSalida, 'diccionarioCompletoOrdenado', 'diccionarioOrdenado', 'cantidadTerminosDiccionarioCompleto', 'cantidadTerminosDiccionario');

save(nombreMatricesDataset, 'terminosDoucmentoSparseMatrixDatasetCompleto', 'terminosDoucmentoSparseMatrixDatasetReducido', 'serieDeTerminosDataset', 'serieDeTerminosDatasetReducido', 'serieDeTerminosPorClaseDataset', 'serieDeTerminosPorClaseDatasetReducido', 'numeroPalabrasPorDocumento', 'numeroPalabrasPorDocumentoReducido', '-append');


cd(directorioActual);
disp('El programa termino correctamente.');
%{
 * Script desarrollado por:
 * Juan Martin Loyola
 * Universidad Nacional de San Luis
 * 2015
%}

%{
 * Script en matlab utilizado para generar las distintas graficas.
%}


%% Antes de comenzar con el script, elimino todas las variables del workspace, cierro todas las figuras y limpio la consola.
% Elimino todas las variables en el workspace.
clear all; 
% Elimino todas las figuras.
close all;
% Clear Command Window.
clc;


%% Elijo sobre que dataset trabajar.
% nombreDataset = 'webkb-train-stemmed';
% nombreDataset = 'webkb-test-stemmed';
% nombreDataset = 'r8-test-all-terms-clean';
% nombreDataset = 'r8-train-all-terms-clean';
% nombreDataset = '20ng-train-stemmed';
nombreDataset = '20ng-test-stemmed';
% nombreDataset = 'test';


%% Obtengo informacion para ubicar los archivos '.mat' y cargo las variables donde se encuentra la informacion con la que se generan las graficas.
directorioActual = pwd;
nombreDiccionariosEntrada = [directorioActual '\Variables del Workspace\' nombreDataset '\diccionarios_' nombreDataset '.mat'];
nombreMatricesEntrada = [directorioActual '\Variables del Workspace\' nombreDataset '\matrices_' nombreDataset '.mat'];

load(nombreDiccionariosEntrada, 'diccionarioCompletoOrdenado', 'diccionarioOrdenado', 'cantidadTerminosDiccionarioCompleto', 'cantidadTerminosDiccionario');
load(nombreMatricesEntrada, 'clasesDiscretizadas', 'uniqueClases', 'serieDeTerminosDataset', 'serieDeTerminosDatasetReducido', 'serieDeTerminosPorClaseDataset', 'serieDeTerminosPorClaseDatasetReducido', 'numeroPalabrasPorDocumento', 'numeroPalabrasPorDocumentoReducido');


%% Creo un directorio donde almacenar las distintas figuras.
directorioFiguras = [directorioActual '\Figuras\' nombreDataset];
% Controlo si existe el directorio. Si no existe creo la carpeta.
if (exist(directorioFiguras, 'dir') ~= 7)
    mkdir(directorioFiguras);
end
cd(directorioFiguras);

% Controlo si existen los directorios. Si no existen los creo.
if (exist([directorioFiguras '\Fig'], 'dir') ~= 7) % La funcion exist() retorna cero si no existe archivo o directorio con dicho nombre. Si existe directorio con dicho nombre retorna 7. (Notar que para otro tipos como archivos, clases, etc existen otros valores de retorno).
    mkdir('Fig');
end
if (exist([directorioFiguras '\Svg'], 'dir') ~= 7)
    mkdir('Svg');
end
if (exist([directorioFiguras '\Eps'], 'dir') ~= 7)
    mkdir('Eps');
end
if (exist([directorioFiguras '\Png'], 'dir') ~= 7)
    mkdir('Png');
end


%% Creo la figura 'Numero de documentos de cada clase'.
% Creo el cuadro para la figura.
f = figure;
% Permite generar un histograma
% Notar que debo pasar como argumento la cantidad de bins y el ancho para
% que la grafica sea como queremos.
% De no colocar la cantidad de bins, matlab usa la cantidad por default.
h = histogram(clasesDiscretizadas, length(uniqueClases));
% Como necesito que sea horizontal debo usar la funcion barh() teniendo que
% tomar los valores del histograma y pasarlos como argumento.
valoresHistograma = h.Values;
% Cierro la figura, ya que la utilizo para armar la figura que sigue.
close(f);
f = figure;
barh(valoresHistograma);
% Coloco la etiqueta al eje y.
ylabel('Clases de documentos');
% Coloco la etiqueta al eje x.
xlabel('Numero de documentos');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Numero de documentos de cada clase en'; nombreDataset};
title(titulo);
% La funcion set() fija propiedades de objetos graficos.
% En este caso del objeto grafico 'gca' que es el Current axes handle.
% Esto nos permite colocar los labels a las barras.
set(gca, 'YTickLabel', uniqueClases); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora
% Cuando la cantidad de clases es grande (dataset 20ng por ejemplo) la
% grafica no queda bien, por lo que debo indicar manualmente donde iran las
% distintas etiquetas.
set(gca,'YTick', 1:1:length(uniqueClases));
% Especifico los limites
set(gca,'YLim',[0 (length(uniqueClases)+1)])

% Guardo la figura en disco.
nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroDocumentosCadaClaseDataset-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroDocumentosCadaClaseDataset-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroDocumentosCadaClaseDataset-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroDocumentosCadaClaseDataset-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc'); % Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo las figuras 'Cantidad de terminos de cada documento'.
% Creo el cuadro para la figura.
f = figure;
% Permite generar un histograma
h = histogram(numeroPalabrasPorDocumento,'BinMethod','integers'); % 'BinMethod','integers' es un BinMethod que nos permite tener tantos bin como enteros tengamos y donde el ancho de cada bin es 1 y se puede tener hasta un limite de 65536 bins.!!
% Coloco la etiqueta al eje x.
xlabel('Cantidad de terminos');
% Coloco la etiqueta al eje y.
ylabel('Numero de documentos');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Cantidad de terminos que tienen los documentos de'; nombreDataset};
title(titulo);
% Especifico los limites del eje x.
set(gca,'XLim',[0 (max(numeroPalabrasPorDocumento)+1)]); % Sumo uno así el último bin se ve entero.
% Selecciono el color de las barras y de los bordes.
color = [0.8549 0.4862 0.1882]; % Color anaranjado.
h.FaceColor = color;
h.EdgeColor = color;
    
nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroPalabrasPorDocumento-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroPalabrasPorDocumento-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroPalabrasPorDocumento-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroPalabrasPorDocumento-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo las figuras 'Cantidad de terminos de cada documento usando intervalos'.
% Creo el cuadro para la figura.
f = figure;
% Obtengo informacion calcular los intervalos y la cantidad de documentos
% en cada intervalo.
minimo = min(numeroPalabrasPorDocumento);
cantidadIntervalos = 10;
tamanioIntervalos = ceil((max(numeroPalabrasPorDocumento + 1) - minimo) / cantidadIntervalos);
edges = minimo : tamanioIntervalos : (minimo + tamanioIntervalos * cantidadIntervalos);
% Obtengo la cantidad de palabras de los documentos discretizada.
numeroPalabrasPorDocumentoDiscreto = discretize(numeroPalabrasPorDocumento, edges);
% Permite generar un histograma
h = histogram(numeroPalabrasPorDocumentoDiscreto,'BinMethod','integers'); % 'BinMethod','integers' es un BinMethod que nos permite tener tantos bin como enteros tengamos y donde el ancho de cada bin es 1 y se puede tener hasta un limite de 65536 bins.!!
% Como necesito que sea horizontal debo usar la funcion barh() teniendo que
% tomar los valores del histograma y pasarlos como argumento.
valoresHistograma = h.Values;
% Cierro la figura, ya que la utilizo para armar la figura que sigue.
close(f);
f = figure;
barh(valoresHistograma);
% Coloco la etiqueta al eje y.
ylabel('Cantidad de terminos');
% Coloco la etiqueta al eje x.
xlabel('Numero de documentos');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Cantidad de terminos que tienen los documentos de'; nombreDataset};
title(titulo);
% Especifico donde iran los Ticks
set(gca,'YTick', 1:cantidadIntervalos);
% Especifico los limites
set(gca,'YLim',[0 (cantidadIntervalos + 1)]);
% Obtengo las etiquetas que iran en los distintos Ticks.
labels = cell(cantidadIntervalos,1);
limiteInferior = minimo;
for i= 1:cantidadIntervalos
    limiteSuperior = limiteInferior + tamanioIntervalos;
    labels{i} = ['[' int2str(limiteInferior) ' - ' int2str(limiteSuperior) ')'];
    limiteInferior = limiteSuperior;
end
% Coloco una etiqueta customizada en cada Tick.
set(gca,'YTickLabel',labels);
    
nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroPalabrasPorDocumentoIntervalos-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroPalabrasPorDocumentoIntervalos-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroPalabrasPorDocumentoIntervalos-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroPalabrasPorDocumentoIntervalos-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo las figuras 'Cantidad de terminos de cada documento reducido'.
% Creo el cuadro para la figura.
f = figure;
% Permite generar un histograma
h = histogram(numeroPalabrasPorDocumentoReducido,'BinMethod','integers'); % 'BinMethod','integers' es un BinMethod que nos permite tener tantos bin como enteros tengamos y donde el ancho de cada bin es 1 y se puede tener hasta un limite de 65536 bins.!!
% Coloco la etiqueta al eje x.
xlabel('Cantidad de terminos');
% Coloco la etiqueta al eje y.
ylabel('Numero de documentos');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Cantidad de terminos que tienen los documentos de'; [nombreDataset '-reducido']};
title(titulo);
% Especifico los limites del eje x.
set(gca,'XLim',[0 (max(numeroPalabrasPorDocumentoReducido)+1)]); % Sumo uno así el último bin se ve entero.
% Selecciono el color de las barras y de los bordes.
color = [0.8549 0.4862 0.1882]; % Color anaranjado.
h.FaceColor = color;
h.EdgeColor = color;
    
nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroPalabrasPorDocumentoReducido-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroPalabrasPorDocumentoReducido-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroPalabrasPorDocumentoReducido-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroPalabrasPorDocumentoReducido-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo las figuras 'Cantidad de terminos de cada documento reducido usando intervalos'.
% Creo el cuadro para la figura.
f = figure;
% Obtengo informacion calcular los intervalos y la cantidad de documentos
% en cada intervalo.
minimo = min(numeroPalabrasPorDocumentoReducido);
cantidadIntervalos = 10;
tamanioIntervalos = ceil((max(numeroPalabrasPorDocumentoReducido + 1) - minimo) / cantidadIntervalos);
edges = minimo : tamanioIntervalos : (minimo + tamanioIntervalos * cantidadIntervalos);
% Obtengo la cantidad de palabras de los documentos discretizada.
numeroPalabrasPorDocumentoReducidoDiscreto = discretize(numeroPalabrasPorDocumentoReducido, edges);
% Permite generar un histograma
h = histogram(numeroPalabrasPorDocumentoReducidoDiscreto,'BinMethod','integers'); % 'BinMethod','integers' es un BinMethod que nos permite tener tantos bin como enteros tengamos y donde el ancho de cada bin es 1 y se puede tener hasta un limite de 65536 bins.!!
% Como necesito que sea horizontal debo usar la funcion barh() teniendo que
% tomar los valores del histograma y pasarlos como argumento.
valoresHistograma = h.Values;
% Cierro la figura, ya que la utilizo para armar la figura que sigue.
close(f);
f = figure;
barh(valoresHistograma);
% Coloco la etiqueta al eje y.
ylabel('Cantidad de terminos');
% Coloco la etiqueta al eje x.
xlabel('Numero de documentos');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Cantidad de terminos que tienen los documentos de'; [nombreDataset '-reducido']};
title(titulo);
% Especifico donde iran los Ticks
set(gca,'YTick', 1:cantidadIntervalos);
% Especifico los limites
set(gca,'YLim',[0 (cantidadIntervalos + 1)]);
% Obtengo las etiquetas que iran en los distintos Ticks.
labels = cell(cantidadIntervalos,1);
limiteInferior = minimo;
for i= 1:cantidadIntervalos
    limiteSuperior = limiteInferior + tamanioIntervalos;
    labels{i} = ['[' int2str(limiteInferior) ' - ' int2str(limiteSuperior) ')'];
    limiteInferior = limiteSuperior;
end
% Coloco una etiqueta customizada en cada Tick.
set(gca,'YTickLabel',labels);
    
nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroPalabrasPorDocumentoReducidoIntervalos-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroPalabrasPorDocumentoReducidoIntervalos-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroPalabrasPorDocumentoReducidoIntervalos-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroPalabrasPorDocumentoReducidoIntervalos-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo la figura 'Cantidad de apariciones de cada termino en el dataset'.
% Creo el cuadro para la figura.
f = figure;
% Permite generar un histograma
% Notar que debo colocar un segundo argumento indicando la cantidad de bins
% a utilizar. De no hacer usa 67 por default.
h = histogram(serieDeTerminosDataset,cantidadTerminosDiccionarioCompleto);
% Coloco la etiqueta al eje x.
xlabel('Terminos del diccionario completo');
% Coloco la etiqueta al eje y.
ylabel('Numero de apariciones');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Numero de apariciones de cada termino en'; nombreDataset};
title(titulo);
% Elimino los 'Ticks' del eje x. (Ya que la cantidad de terminos es muy
% grande).
set(gca,'XTick',[])

nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroRepeticionesTerminosDataset-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroRepeticionesTerminosDataset-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroRepeticionesTerminosDataset-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroRepeticionesTerminosDataset-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');



%% Creo la figura 'Terminos mas repetidos en el dataset'.
% Con esto puedo obtener la cantidad de veces que se repite cada termino en
% el dataset.
cantidadRepeticionTerminos = h.Values;
% Ordeno los valores para saber cuales son los terminos que mas aparece y
% cuales son los terminos que menos aparecen. En la variable valores tengo
% todas las cantidades ordenadas de menor a mayor y en la variable
% indiceValores tengo los indices donde se encontraban cada uno de estos.
[valores, indiceValores] = sort(cantidadRepeticionTerminos);

% Creo el cuadro para la figura.
f = figure;
numeroElementosAMostrar = 10;
% Permite generar un grafico de barras de forma horizontal.
barh(valores(end-numeroElementosAMostrar+1 : end));
% Coloco la etiqueta al eje y.
ylabel('Terminos que mas se repiten');
% Coloco la etiqueta al eje x.
xlabel('Numero de apariciones');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Terminos mas repetidos en'; nombreDataset};
title(titulo);

% La funcion set() fija propiedades de objetos graficos.
% En este caso del objeto grafico 'gca' que es el Current axes handle.
% Esto nos permite colocar los labels a las barras.
indicesTerminosMasRepetidosDataset = indiceValores(end-numeroElementosAMostrar+1 : end);
set(gca,'YTickLabel',diccionarioCompletoOrdenado(indicesTerminosMasRepetidosDataset)); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora

nombreFiguraFig = [directorioFiguras '\Fig\' 'terminosMasRepetidosDataset-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'terminosMasRepetidosDataset-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'terminosMasRepetidosDataset-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'terminosMasRepetidosDataset-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo la figura 'Terminos mas repetidos en el dataset'. Utilizando la version stacked de barh.
% Armo la matriz que tiene por cada termino una fila y una columna por cada
% clase. Para cada termino indico la cantidad de veces que ocurre dicho
% termino en los documentos de cada clase.
valoresStacked = zeros(numeroElementosAMostrar, length(uniqueClases));
for i = 1:numeroElementosAMostrar
    for j = 1:length(uniqueClases)
        indicePalabra = indicesTerminosMasRepetidosDataset(i);
        repeticionTermClase = numel(find(serieDeTerminosPorClaseDataset(j,:) == indicePalabra));
        valoresStacked(i,j) = repeticionTermClase;
    end
end

% Creo el cuadro para la figura.
f = figure;
% Permite generar un grafico de barras de forma horizontal.
barh(valoresStacked, 'stacked');
% Coloco la etiqueta al eje y.
ylabel('Terminos que mas se repiten');
% Coloco la etiqueta al eje x.
xlabel('Numero de apariciones');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Terminos mas repetidos en'; nombreDataset; 'versión stacked'};
title(titulo);

% La funcion set() fija propiedades de objetos graficos.
% En este caso del objeto grafico 'gca' que es el Current axes handle.
% Esto nos permite colocar los labels a las barras.
set(gca,'YTickLabel',diccionarioCompletoOrdenado(indicesTerminosMasRepetidosDataset)); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora

% Coloco la leyenda.
legend(uniqueClases,'Location','Best')

nombreFiguraFig = [directorioFiguras '\Fig\' 'terminosMasRepetidosDatasetStacked-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'terminosMasRepetidosDatasetStacked-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'terminosMasRepetidosDatasetStacked-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'terminosMasRepetidosDatasetStacked-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo la figura 'Cantidad de apariciones de cada termino en el dataset (diccionario reducido)'.
% Creo el cuadro para la figura.
f = figure;
% Permite generar un histograma
% Notar que debo colocar un segundo argumento indicando la cantidad de bins
% a utilizar. De no hacer usa 67 por default.
h = histogram(serieDeTerminosDatasetReducido,cantidadTerminosDiccionario);
% Coloco la etiqueta al eje x.
xlabel('Terminos del diccionario reducido');
% Coloco la etiqueta al eje y.
ylabel('Numero de apariciones');
% Coloco el titulo a la figura.
% Elimino los 'Ticks' del eje x. (Ya que la cantidad de terminos es muy
% grande).
set(gca,'XTick',[])
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Numero de apariciones de cada termino en'; [nombreDataset '-reducido']};
title(titulo);

nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo la figura 'Terminos mas repetidos en dataset reducido'
% Con esto puedo obtener la cantidad de veces que se repite cada termino en
% el dataset.
cantidadRepeticionTerminos = h.Values;
% Ordeno los valores para saber cuales son los terminos que mas aparece y
% cuales son los terminos que menos aparecen. En la variable valores tengo
% todas las cantidades ordenadas de menor a mayor y en la variable
% indiceValores tengo los indices donde se encontraban cada uno de estos.
[valores, indiceValores] = sort(cantidadRepeticionTerminos);

% Creo el cuadro para la figura.
f = figure;
% Permite generar un grafico de barras horizontal.
barh(valores(end-numeroElementosAMostrar+1 : end));
% Coloco la etiqueta al eje y.
ylabel('Terminos que mas se repiten');
% Coloco la etiqueta al eje x.
xlabel('Numero de apariciones');
% La funcion set() fija propiedades de objetos graficos.
% En este caso del objeto grafico 'gca' que es el Current axes handle.
% Esto nos permite colocar los labels a las barras.
indicesTerminosMasRepetidosDatasetReducido = indiceValores(end-numeroElementosAMostrar+1 : end);
set(gca,'YTickLabel',diccionarioOrdenado(indicesTerminosMasRepetidosDatasetReducido)); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Terminos mas repetidos en'; [nombreDataset '-reducido']};
title(titulo);

nombreFiguraFig = [directorioFiguras '\Fig\' 'terminosMasRepetidosDatasetReducido-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'terminosMasRepetidosDatasetReducido-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'terminosMasRepetidosDatasetReducido-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'terminosMasRepetidosDatasetReducido-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo la figura 'Terminos mas repetidos en el dataset reducido'. Utilizando la version stacked de barh.
% Armo la matriz que tiene por cada termino una fila y una columna por cada
% clase. Para cada termino indico la cantidad de veces que ocurre dicho
% termino en los documentos de cada clase.
valoresStacked = zeros(numeroElementosAMostrar, length(uniqueClases));
for i = 1:numeroElementosAMostrar
    for j = 1:length(uniqueClases)
        indicePalabra = indicesTerminosMasRepetidosDatasetReducido(i);
        repeticionTermClase = numel(find(serieDeTerminosPorClaseDatasetReducido(j,:) == indicePalabra));
        valoresStacked(i,j) = repeticionTermClase;
    end
end

% Creo el cuadro para la figura.
f = figure;
% Permite generar un grafico de barras de forma horizontal.
barh(valoresStacked, 'stacked');
% Coloco la etiqueta al eje y.
ylabel('Terminos que mas se repiten');
% Coloco la etiqueta al eje x.
xlabel('Numero de apariciones');
% Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
% titulos con mas de una linea.
titulo = {'Terminos mas repetidos en'; [nombreDataset '-reducido']; 'versión stacked'};
title(titulo);

% La funcion set() fija propiedades de objetos graficos.
% En este caso del objeto grafico 'gca' que es el Current axes handle.
% Esto nos permite colocar los labels a las barras.
set(gca,'YTickLabel',diccionarioOrdenado(indicesTerminosMasRepetidosDatasetReducido)); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora

% Coloco la leyenda.
legend(uniqueClases,'Location','Best') % Al parecer se debe escribir asi (sin el ';' al final) ya que de otra forma se resetea la posicion de la leyenda.

nombreFiguraFig = [directorioFiguras '\Fig\' 'terminosMasRepetidosDatasetReducidoStacked-' nombreDataset];
nombreFiguraSvg = [directorioFiguras '\Svg\' 'terminosMasRepetidosDatasetReducidoStacked-' nombreDataset];
nombreFiguraEps = [directorioFiguras '\Eps\' 'terminosMasRepetidosDatasetReducidoStacked-' nombreDataset];
nombreFiguraPng = [directorioFiguras '\Png\' 'terminosMasRepetidosDatasetReducidoStacked-' nombreDataset];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


%% Creo graficas para cada clase tomando en cuenta el diccionario completo y el diccionario reducido.
numeroElementosAMostrarPorClase = 10;
for i = 1:length(uniqueClases)
    %% Creo las figuras 'Cantidad de apariciones de cada termino del diccionarioCompleto en cada clase'.
    % Creo el cuadro para la figura.
    f = figure;
    %% cantidadTerminosDistintosClase = length(unique(serieDeTerminosPorClaseDataset(i,:))); Esta variable era usada con la otra forma de llamar a la funcion histogram()
    % Permite generar un histograma
    % Notar que debo colocar un segundo argumento indicando la cantidad de bins
    % a utilizar. De no hacer usa 67 por default.
    % Notar tambien que aqui se hace
    % serieDeTerminosPorClaseDataset(i,posicionesSinCeros) ya que esta estructura se
    % encuentra 'rellenada' con ceros para hacer del tamaño mas grande. Asi
    % solo utilizamos aquellas posiciones sin ceros.
    posicionesSinCeros = find(serieDeTerminosPorClaseDataset(i,:));
    % h = histogram(serieDeTerminosPorClaseDataset(i,posicionesSinCeros),cantidadTerminosDistintosClase);
    h = histogram(serieDeTerminosPorClaseDataset(i,posicionesSinCeros),'BinMethod','integers'); % 'BinMethod','integers' es un BinMethod que nos permite tener tantos bin como enteros tengamos y donde el ancho de cada bin es 1 y se puede tener hasta un limite de 65536 bins.!!
    % Coloco la etiqueta al eje x.
    xlabel('Terminos del diccionario completo');
    % Coloco la etiqueta al eje y.
    ylabel('Numero de apariciones');
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    titulo = {'Numero de apariciones de cada termino en'; [nombreDataset ' en la clase ' uniqueClases{i}]};
    title(titulo);
    % Elimino los 'Ticks' del eje x. (Ya que la cantidad de terminos es muy
    % grande).
    set(gca,'XTick',[])

    % Notar que existen clases cuyo nombre contiene un punto '.' en el
    % nombre. Asi, se utiliza la funcion strrep() para reemplazar los
    % puntos en el nombre de clase por el caracter '-'.    
    nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroRepeticionesTerminosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroRepeticionesTerminosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroRepeticionesTerminosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraPng = [directorioFiguras '\Png\' 'numeroRepeticionesTerminosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    saveas(f, nombreFiguraFig, 'fig');
    saveas(f, nombreFiguraSvg, 'svg');
    saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
    saveas(f, nombreFiguraPng, 'png');


    %% Creo la figura 'Terminos mas repetidos en el dataset'.
    % Con esto puedo obtener la cantidad de veces que se repite cada termino en
    % el dataset. 
    % No tengo en cuenta los elementos cuyo valor es cero. Notar que esto
    % solo sucede en estas subSeries que no incluyen todos los terminos de
    % los diccionarios.
    % Para ver porque pueden aparecer ceros mire el siguiente ejemplo:
    % Sea A=[3 3 3 6 6 6 8 8 7 1], cuando hacemos h=histogram(A)
    % Obtenemos 5 bins con la cantidad de veces que se repiten los numeros
    % uno, tres, seis, siete y ocho.
    % Cuando obtenemos los valores del histograma (valores=h.Values) no
    % solo obtenemos esos valores sino que tambien la cantidad de veces que
    % aparece cada numero que se encuentra en el medio entre los limites
    % inferior y superior (uno y ocho). Asi se indicara que el dos aparece
    % cero veces al igual que el cuatro y el cinco.
    cantidadRepeticionTerminosPorClase = h.Values(find(h.Values));
    % Ordeno los valores para saber cuales son los terminos que mas aparece y
    % cuales son los terminos que menos aparecen. En la variable valores tengo
    % todas las cantidades ordenadas de menor a mayor y en la variable
    % indiceValores tengo los indices donde se encontraban cada uno de estos.
    [valores, indiceValores] = sort(cantidadRepeticionTerminosPorClase);

    % Creo el cuadro para la figura.
    f = figure;
    % Permite generar un grafico de barras horizontal.
    barh(valores(end-numeroElementosAMostrarPorClase+1 : end));
    % Coloco la etiqueta al eje y.
    ylabel('Terminos que mas se repiten');
    % Coloco la etiqueta al eje x.
    xlabel('Numero de apariciones');
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    titulo = {'Terminos mas repetidos en'; [nombreDataset ' en la clase ' uniqueClases{i}]};
    title(titulo);

    % Obtengo los terminos que se utilizaron en esta clase de documento.
    terminosUsadosEnClase = unique(serieDeTerminosPorClaseDataset(i,posicionesSinCeros));
    % Obtengo el indice en el diccionario de los terminos utilizados en
    % esta clase.
    indiceTerminosEnDiccionario = terminosUsadosEnClase(indiceValores(end-numeroElementosAMostrarPorClase+1 : end));
    % La funcion set() fija propiedades de objetos graficos.
    % En este caso del objeto grafico 'gca' que es el Current axes handle.
    % Esto nos permite colocar los labels a las barras.
    set(gca,'YTickLabel',diccionarioCompletoOrdenado(indiceTerminosEnDiccionario)); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora

    % Notar que existen clases cuyo nombre contiene un punto '.' en el
    % nombre. Asi, se utiliza la funcion strrep() para reemplazar los
    % puntos en el nombre de clase por el caracter '-'.    
    nombreFiguraFig = [directorioFiguras '\Fig\' 'terminosMasRepetidosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraSvg = [directorioFiguras '\Svg\' 'terminosMasRepetidosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraEps = [directorioFiguras '\Eps\' 'terminosMasRepetidosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraPng = [directorioFiguras '\Png\' 'terminosMasRepetidosDataset-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    saveas(f, nombreFiguraFig, 'fig');
    saveas(f, nombreFiguraSvg, 'svg');
    saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
    saveas(f, nombreFiguraPng, 'png');
    
    
    
    %% Creo las figuras 'Cantidad de apariciones de cada termino del diccionario en cada clase'.
    % Creo el cuadro para la figura.
    f = figure;
    %% cantidadTerminosDistintosClase = length(unique(serieDeTerminosPorClaseDatasetReducido(i,:))); Esta variable era necesaria para la forma en la que se llamaba la funcion histogram() antes.
    % Permite generar un histograma
    % Notar que debo colocar un segundo argumento indicando la cantidad de bins
    % a utilizar. De no hacer usa 67 por default.
    % Notar tambien que aqui se hace
    % serieDeTerminosPorClaseDataset(i,posicionesSinCeros) ya que esta estructura se
    % encuentra 'rellenada' con ceros para hacer del tamaño mas grande. Asi
    % solo utilizamos aquellas posiciones sin ceros.
    posicionesSinCeros = find(serieDeTerminosPorClaseDatasetReducido(i,:));
    % h = histogram(serieDeTerminosPorClaseDataset(i,posicionesSinCeros),cantidadTerminosDistintosClase);
    h = histogram(serieDeTerminosPorClaseDatasetReducido(i,posicionesSinCeros),'BinMethod','integers'); % 'BinMethod','integers' es un BinMethod que nos permite tener tantos bin como enteros tengamos y donde el ancho de cada bin es 1 y se puede tener hasta un limite de 65536 bins.!!
    % Coloco la etiqueta al eje x.
    xlabel('Terminos del diccionario reducido');
    % Coloco la etiqueta al eje y.
    ylabel('Numero de apariciones');
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    titulo = {'Numero de apariciones de cada termino en'; [nombreDataset '-reducido en la clase ' uniqueClases{i}]};
    title(titulo);
    % Elimino los 'Ticks' del eje x. (Ya que la cantidad de terminos es muy
    % grande).
    set(gca,'XTick',[])

    % Notar que existen clases cuyo nombre contiene un punto '.' en el
    % nombre. Asi, se utiliza la funcion strrep() para reemplazar los
    % puntos en el nombre de clase por el caracter '-'.
    nombreFiguraFig = [directorioFiguras '\Fig\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraSvg = [directorioFiguras '\Svg\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraEps = [directorioFiguras '\Eps\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraPng = [directorioFiguras '\Png\' 'numeroRepeticionesTerminosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    saveas(f, nombreFiguraFig, 'fig');
    saveas(f, nombreFiguraSvg, 'svg');
    saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
    saveas(f, nombreFiguraPng, 'png');


    %% Creo la figura 'Terminos mas repetidos en el dataset reducido'.
    % Con esto puedo obtener la cantidad de veces que se repite cada termino en
    % el dataset. 
    % No tengo en cuenta los elementos cuyo valor es cero. Notar que esto
    % solo sucede en estas subSeries que no incluyen todos los terminos de
    % los diccionarios.
    % Para ver porque pueden aparecer ceros mire el siguiente ejemplo:
    % Sea A=[3 3 3 6 6 6 8 8 7 1], cuando hacemos h=histogram(A)
    % Obtenemos 5 bins con la cantidad de veces que se repiten los numeros
    % uno, tres, seis, siete y ocho.
    % Cuando obtenemos los valores del histograma (valores=h.Values) no
    % solo obtenemos esos valores sino que tambien la cantidad de veces que
    % aparece cada numero que se encuentra en el medio entre los limites
    % inferior y superior (uno y ocho). Asi se indicara que el dos aparece
    % cero veces al igual que el cuatro y el cinco.
    cantidadRepeticionTerminosPorClase = h.Values(find(h.Values));
    % Ordeno los valores para saber cuales son los terminos que mas aparece y
    % cuales son los terminos que menos aparecen. En la variable valores tengo
    % todas las cantidades ordenadas de menor a mayor y en la variable
    % indiceValores tengo los indices donde se encontraban cada uno de estos.
    [valores, indiceValores] = sort(cantidadRepeticionTerminosPorClase);

    % Creo el cuadro para la figura.
    f = figure;
    % Permite generar un grafico de barras horizontal.
    barh(valores(end-numeroElementosAMostrarPorClase+1 : end));
    % Coloco la etiqueta al eje y.
    ylabel('Terminos que mas se repiten');
    % Coloco la etiqueta al eje x.
    xlabel('Numero de apariciones');
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    titulo = {'Terminos mas repetidos en'; [nombreDataset '-reducido en la clase ' uniqueClases{i}]};
    title(titulo);

    % Obtengo los terminos que se utilizaron en esta clase de documento.
    terminosUsadosEnClase = unique(serieDeTerminosPorClaseDatasetReducido(i,posicionesSinCeros));
    % Obtengo el indice en el diccionario de los terminos utilizados en
    % esta clase.
    indiceTerminosEnDiccionario = terminosUsadosEnClase(indiceValores(end-numeroElementosAMostrarPorClase+1 : end));
    % La funcion set() fija propiedades de objetos graficos.
    % En este caso del objeto grafico 'gca' que es el Current axes handle.
    % Esto nos permite colocar los labels a las barras.
    set(gca,'YTickLabel',diccionarioOrdenado(indiceTerminosEnDiccionario)); % Antes los distintos labels eran asignados con {diccionarioCompletoOrdenado{indiceValores(end-10:end)}}, pero matlab sugirio reemplazarlo por lo que esta ahora

    % Notar que existen clases cuyo nombre contiene un punto '.' en el
    % nombre. Asi, se utiliza la funcion strrep() para reemplazar los
    % puntos en el nombre de clase por el caracter '-'.
    nombreFiguraFig = [directorioFiguras '\Fig\' 'terminosMasRepetidosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraSvg = [directorioFiguras '\Svg\' 'terminosMasRepetidosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraEps = [directorioFiguras '\Eps\' 'terminosMasRepetidosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    nombreFiguraPng = [directorioFiguras '\Png\' 'terminosMasRepetidosDatasetReducido-' nombreDataset '-' strrep(uniqueClases{i}, '.', '-')];
    saveas(f, nombreFiguraFig, 'fig');
    saveas(f, nombreFiguraSvg, 'svg');
    saveas(f, nombreFiguraEps, 'epsc');% Guarda la figura en formato eps color.
    saveas(f, nombreFiguraPng, 'png');
end


cd(directorioActual);
disp('El programa termino correctamente.');
function [ npTotal, npDistintas, npBlackList, npMasFrecuentesCadaClase ] = informacionDocumentosParciales(documentoParcial, blackList, indicesTerminosMasFrecPorClase)
%INFORMACIONDOCUMENTOSPARCIALES Funcion que retorna información para el
%clasificador que toma la decision de cuando parar.
%   npTotal = numero de palabras total
%   npBlackList = numero de palabras sin considerar las que se encuentran
%   en la BlackList.
%   npMasFrecuentesCadaClase = numero de palabras mas frecuentes de cada
%   clase (vector).

%   documentoParcial = matriz sparse que tiene el documento parcial. El
%   documento es representado como una secuencia de indices del diccionario
%   (haciendo referencia a los terminos del diccionario).
%   blackList = lista que contiene aquellas palabras que no interesa
%   contar, por ejemplo 'the', 'a', 'and' ,etc.
%   indicesTerminosMasFrecPorClase = Una matriz donde se almacenan los
%   indices de aquellos terminos con mayor frecuencia para cada clase.

    npTotal = length(documentoParcial);
    npDistintas = length(unique(documentoParcial));

    blackWords = 0;
    if (~isempty(blackList))
        for i= 1:size(blackList)
            blackWords = blackWords + length(find(documentoParcial==blackList(i)));
        end
    end
    npBlackList = npTotal - blackWords;
    
    if (~isempty(indicesTerminosMasFrecPorClase))
        % Notar que indicesTerminosMasFrecPorClase es un cell de 1x8 donde
        % cada celda es un arreglo de 25x1 terminos.
        cantClases = size(indicesTerminosMasFrecPorClase,2);
        cantTerminos = length(indicesTerminosMasFrecPorClase{1});
        
        npMasFrecuentesCadaClase = zeros(1,cantClases);
        
        for i= 1:cantClases
            for j= 1:cantTerminos
                npMasFrecuentesCadaClase(i) = npMasFrecuentesCadaClase(i) + length(find(documentoParcial==indicesTerminosMasFrecPorClase{i}(j)));
            end
        end
    else
        npMasFrecuentesCadaClase = -1;
    end
end

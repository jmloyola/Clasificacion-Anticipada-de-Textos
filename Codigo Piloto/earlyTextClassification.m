clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;
directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset];
cd(directorioVariablesWorkspace);

nombreMatrices = [nombreDataset '_Matrices.mat'];
load(nombreMatrices);

nombreBlackWords = [nombreDataset '_BlackWords.mat'];
load(nombreBlackWords, 'blackList');

nombreTerminosPorClase = [nombreDataset '_TerminosPorClase.mat'];
load(nombreTerminosPorClase, 'indicesTerminosMasFrecPorClase');

classex=unique(Ytrain);
Yones=-ones(size(Ytrain,1),length(classex));
for i=1:length(classex),
    Yones(find(Ytrain==classex(i)),i)=1;
end
YTones=-ones(size(Ytest,1),length(classex));
for i=1:length(classex),
    YTones(find(Ytest==classex(i)),i)=1;
end

%% Cargo el modelo CTIP entrenado
pathModeloEntrenamiento = [directorioVariablesWorkspace '\' nombreDataset '_ModeloEntrenado.mat'];
load(pathModeloEntrenamiento, 'NB');


%% Parametros
alfa = 2; % Lectura minima de ventanas.
beta = 3; % Cantidad de ventanas de confirmacion.


%% Realizo las predicciones incrementales (ventana a ventana)
tamanioVentana = 1;
ventanas = 1:tamanioVentana:100;
%ventanas = 1:tamanioVentana:35;
ventanas(end+1) = size(sTest,2);
%ventanas = 1:tamanioVentana:size(sTest,2);

infoDocumentosParciales = cell(size(Xtest,1), length(ventanas));
infoHistorica = cell(size(Xtest,1), length(ventanas));
auxAverage = cell(size(Xtest,1), length(ventanas));
indiceVentanas = zeros(size(Xtest,1), length(ventanas));
probCadaClase = cell(size(Xtest,1), length(ventanas));
clasePredicha = zeros(size(Xtest,1), length(ventanas));


for j=1:length(ventanas),
    j
    if ventanas(j) > 100
        print j
    end
    close all;
    rXtest=sparse(size(Xtest,1),size(Xtest,2));
    %% Simulo el conjunto de atributos disminuidos
    for i=1:size(Xtest,1),        
        noz=length(find(sTest(i,:)~=0));
        if (noz <= ventanas(j))
            ntermssf = noz;
        else
            ntermssf = ventanas(j);
        end
        
        indiceVentanas(i,j) = ntermssf;
        
        doc = full(sTest(i,1:ntermssf));
        documentoParcial = doc(find(doc));
        [npTotal, npDistintas, npBlackList, npMasFrecuentesCadaClase] = informacionDocumentosParciales(documentoParcial, blackList, indicesTerminosMasFrecPorClase);
        
        infoDocumentosParciales{i,j} = [npTotal, npDistintas, npBlackList, npMasFrecuentesCadaClase];
        
        myox=1;
        wdix=1;
        freqtsof=sparse(1,size(Xtest,2));
        while myox<=ntermssf ,
            if sTest(i,wdix)~=0,
                freqtsof(sTest(i,wdix))=freqtsof(sTest(i,wdix))+1;
                myox=myox+1;
            end
            wdix=wdix+1;
        end
        rXtest(i,:)=freqtsof;
    end
    Xtestv=rXtest;
    
    %% Clasifico con Naive Bayes y estimo la performance 
    [NB0] = MNNaiveBayes(Xtestv,[],0,NB);
    
    if (j==1)
        for i=1:size(Xtest,1)
            probCadaClase{i,j} = NB0.Pr(i,:);
            clasePredicha(i,j) = NB0.pred(i);
            auxAverage{i,j} = NB0.Pr(i,:);
            infoHistorica{i,j} = NB0.Pr(i,:); % Average probabilidad de cada clase.
        end
    else
        for i=1:size(Xtest,1)
            probCadaClase{i,j} = NB0.Pr(i,:);
            clasePredicha(i,j) = NB0.pred(i);
            auxAverage{i,j} = auxAverage{i,j-1} + NB0.Pr(i,:);
            infoHistorica{i,j} = auxAverage{i,j} / j; % Average probabilidad de cada clase.
        end
    end
    
    pred=NB0.pred;
    
    clear pred;  
end





cd(directorioActual);

disp('El programa finalizo exitosamente');

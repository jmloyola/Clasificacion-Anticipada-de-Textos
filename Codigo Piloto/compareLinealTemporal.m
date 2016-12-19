clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;
directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset];
cd(directorioVariablesWorkspace);

nombreArchivo = [nombreDataset '_Matrices.mat'];
load(nombreArchivo);

nombreArchivo = [nombreDataset '_InfoDocumentosParciales.mat'];
load(nombreArchivo, 'clasePredicha', 'infoHistorica', 'indiceVentanas', 'tamanioVentana');

%%
tamanioVentana=1;

nombreArchivo = [nombreDataset '_DMC_dataset.mat'];
load(nombreArchivo);

% clop_model = neural;
% clop_model = kridge;
% clop_model = naive;
clop_model = gentleboost;
% clop_model = j48;

nombreArchivo= [nombreDataset '_DMC_' clop_model.name '.mat'];
load(nombreArchivo, 'training_resu', 'trained_model', 'test_resu', 'precision_measure_stop', 'recall_measure_stop', 'f1_measure_stop', 'precision_measure_continue', 'recall_measure_continue', 'f1_measure_continue', 'XtrainDMC', 'YtrainDMC', 'XtestDMC', 'YtestDMC', 'numeroDocumento');


cd(directorioActual);


%% Parametros
alfa = 2; % Lectura minima de ventanas.
beta = 3; % Cantidad de ventanas de confirmacion.


idxDocumentosTest = find(isForTraining == 0);
cantidadDocumentosTest = length(idxDocumentosTest);
cantidadVentanas = size(infoHistorica,2);
tiempoCorte = ones(cantidadDocumentosTest, 1) * (cantidadVentanas - alfa);
clasePredichaLineal = zeros(cantidadDocumentosTest,1);
clasePredichaTemp = zeros(cantidadDocumentosTest,1);

idxProbPrimerClase = length(infoHistorica{1,1}) + 1 + 1;
cantClases = length(unique(Ytrain));

cantidadTerminosDocumentos = indiceVentanas(idxDocumentosTest,cantidadVentanas);

for i=1:cantidadDocumentosTest,
    i
    clasePredichaLineal(i) = clasePredicha(idxDocumentosTest(i), cantidadVentanas);
    
    idxDoc = find(numeroDocumento' == idxDocumentosTest(i));
    k=1;
    for j=alfa:cantidadVentanas,
        %test_data = data(XtestDMC(idxDoc(k),:), YtestDMC(idxDoc(k)));
        %test_resu = test(trained_model, test_data);
        
        if (sign(test_resu.X(idxDoc(k),:)) == 1)
            tiempoCorte(i) = k;
            probabilidades = XtestDMC(idxDoc(k),idxProbPrimerClase:idxProbPrimerClase+cantClases-1);
            clasePredichaTemp(i) = find(probabilidades == max(probabilidades));
            break;
        end
        if ((j == cantidadVentanas - alfa) || (j*tamanioVentana >= cantidadTerminosDocumentos(i)))
            tiempoCorte(i) = k;
            probabilidades = XtestDMC(idxDoc(k),idxProbPrimerClase:idxProbPrimerClase+cantClases-1);
            clasePredichaTemp(i) = find(probabilidades == max(probabilidades));
            break;
        end
        k = k + 1;
    end
end

TPLineal = find((clasePredichaLineal-Ytest(idxDocumentosTest)) == 0);
TPTemporal = find((clasePredichaTemp-Ytest(idxDocumentosTest)) == 0);

interseccionTP = find(((clasePredichaLineal-Ytest(idxDocumentosTest)) == 0) & ((clasePredichaTemp-Ytest(idxDocumentosTest)) == 0) == 1);
tpl_fpt = find(((clasePredichaLineal-Ytest(idxDocumentosTest)) == 0) & ((clasePredichaTemp-Ytest(idxDocumentosTest)) ~= 0) == 1);
fpl_tpt = find(((clasePredichaLineal-Ytest(idxDocumentosTest)) ~= 0) & ((clasePredichaTemp-Ytest(idxDocumentosTest)) == 0) == 1);


cant_terminos_ahorrados = zeros(cantidadDocumentosTest,1);
for i=1:length(interseccionTP),
    cant_terminos_ahorrados(i) = cantidadTerminosDocumentos(i) - ( (tiempoCorte(i) * tamanioVentana) + ( (alfa-1)* tamanioVentana) );
end

cd(directorioVariablesWorkspace);

nombreArchivoSalida = [nombreDataset '_compareLinealTemporal_' clop_model.name '.mat'];
save(nombreArchivoSalida, 'clasePredichaLineal', 'clasePredichaTemp', 'tiempoCorte', 'cantidadDocumentosTest', 'cantidadVentanas', 'alfa', 'beta');

cd(directorioActual);

cant_TPLineal = length(TPLineal)
cant_TPTemporal = length(TPTemporal)
cant_interseccionTP = length(interseccionTP)
cant_tpl_fpt = length(tpl_fpt)
cant_fpl_tpt = length(fpl_tpt)
avg_cantidadTerminosDocumentos = mean(cantidadTerminosDocumentos)
avg_cant_terminos_ahorrados = mean(cant_terminos_ahorrados)


disp('El programa finalizo exitosamente');

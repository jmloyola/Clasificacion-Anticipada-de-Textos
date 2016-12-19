clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;
directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset];
cd(directorioVariablesWorkspace);

nombreArchivo = [nombreDataset '_Matrices.mat'];
load(nombreArchivo);

nombreArchivo = [nombreDataset '_InfoDocumentosParciales.mat'];
load(nombreArchivo);


% directorioTipoDocumentos = 'C:\Users\Juan Martin\Documents\GitHub\Clasificacion-Anticipada-de-Textos\TiposDocumentos\Variables del Workspace\';

% pathTipoDocumentos = [directorioTipoDocumentos nombreDataset '\' nombreDataset '_TipoDocumentos.mat'];
% load(pathTipoDocumentos);


classex=unique(Ytrain);
Yones=-ones(size(Ytrain,1),length(classex));
for i=1:length(classex),
    Yones(find(Ytrain==classex(i)),i)=1;
end
YTones=-ones(size(Ytest,1),length(classex));
for i=1:length(classex),
    YTones(find(Ytest==classex(i)),i)=1;
end


%% Parametros
alfa = 2; % Lectura minima de ventanas.
beta = 3; % Cantidad de ventanas de confirmacion.
porcentajeTrain = 0.60;
cantidadDocumentos = size(infoHistorica,1);
cantidadVentanas = size(infoHistorica,2);
isForTraining = zeros(cantidadDocumentos, 1);

nombreArchivo = [nombreDataset '_DMC_dataset.mat'];
if (exist(nombreArchivo, 'file') ~= 2),
    cantDocCadaClase = zeros(length(classex),1);
    docCadaClase = {};
    for i=1:length(classex),
        cantDocCadaClase(i) = length(find(Ytest == i));
        docCadaClase = [docCadaClase, find(Ytest == i)];
        isForTraining(docCadaClase{1,i}(1:ceil(cantDocCadaClase(i)* porcentajeTrain))) = 1;
    end

    %% Genero dataset para dmc.
    XtrainDMC = [];
    YtrainDMC = [];
    XtestDMC = [];
    YtestDMC = [];
    numeroDocumento = [];

    for i=1:cantidadDocumentos,
        i

        if (isForTraining(i)==1)
            for j=alfa:cantidadVentanas,
                j
                XtrainDMC = [XtrainDMC; infoHistorica{i,j}, j, probCadaClase{i,j}, infoDocumentosParciales{i,j}];
                if clasePredicha(i,j) == Ytest(i)
                    YtrainDMC = [YtrainDMC; 1];
                else
                    YtrainDMC = [YtrainDMC; -1];
                end
            end
        else
            for j=alfa:cantidadVentanas,
                j
                XtestDMC = [XtestDMC; infoHistorica{i,j}, j, probCadaClase{i,j}, infoDocumentosParciales{i,j}];
                numeroDocumento = [numeroDocumento, i];
                if clasePredicha(i,j) == Ytest(i)
                    YtestDMC = [YtestDMC; 1];
                else
                    YtestDMC = [YtestDMC; -1];
                end
            end
        end
    end


    cd(directorioVariablesWorkspace);

    nombreArchivoSalida = [nombreDataset '_DMC_dataset.mat'];
    save(nombreArchivoSalida, 'XtrainDMC', 'YtrainDMC', 'XtestDMC', 'YtestDMC', 'numeroDocumento', 'isForTraining');

else
    load(nombreArchivo);
end
    
cd(directorioActual);

training_data = data(XtrainDMC, YtrainDMC);
%clear Xtrain Ytrain

test_data = data(XtestDMC, YtestDMC);
%clear Xtest

% clop_model = neural;
% clop_model = kridge;
% clop_model = naive;
clop_model = gentleboost;
% clop_model = j48;

[training_resu, trained_model] = train(clop_model, training_data);
test_resu = test(trained_model, test_data);

error_cost = 0;
cantVen = (cantidadVentanas-alfa+1);
cantDoc = ceil(length(Xtest) / cantVen);


%% error_cost = early_risk_detection_error(sign(test_resu.X), sign(test_resu.X), test_resu.Y, ventana);



[tr_ber, e1, e2, tr_ebar]   = balanced_errate(round(test_resu.X),test_resu.Y);
% [tr_ber, e1, e2, tr_ebar]   = balanced_errate(test_resu.X,test_resu.Y);
fprintf('TEST BER=%5.2f +-%5.2f%%\n', 100*tr_ber, 100*tr_ebar); 


[precision_measure_stop,recall_measure_stop,f1_measure_stop] = eval_prf(test_resu.X,test_resu.Y,1)
[precision_measure_continue,recall_measure_continue,f1_measure_continue] = eval_prf(test_resu.X,test_resu.Y,-1)
% [precision_measure,recall_measure,frv_refull] = eval_prf(test_resu.X,test_resu.Y,1);

qty = length(test_resu.X)
qty_stop = length(find(sign(test_resu.X) == 1))
qty_continue = length(find(sign(test_resu.X) == -1))

%[~,AUCv_refull,~, ~] = roc_2(round(test_resu.X), YtestDMC);
% [~,AUCv_refull,~, ~] = roc_2(test_resu.X, Ytest);
  
accNBMM=(length(find((round(test_resu.X)-test_resu.Y)==0))./length(test_resu.Y)).*100


cd(directorioVariablesWorkspace);

nombreArchivoSalida = [nombreDataset '_DMC_' clop_model.name '.mat'];
save(nombreArchivoSalida, 'training_resu', 'trained_model', 'test_resu', 'precision_measure_stop', 'recall_measure_stop', 'f1_measure_stop', 'precision_measure_continue', 'recall_measure_continue', 'f1_measure_continue', 'XtrainDMC', 'YtrainDMC', 'XtestDMC', 'YtestDMC', 'numeroDocumento');

cd(directorioActual);

disp('El programa finalizo exitosamente');

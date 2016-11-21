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

cd(directorioActual);

%% Parametros
alfa = 2; % Lectura minima de ventanas.
beta = 3; % Cantidad de ventanas de confirmacion.


%% Genero dataset para dmc.
cantidadDocumentos = size(infoHistorica,1);
cantidadVentanas = size(infoHistorica,2);
XtrainDMC = zeros(cantidadDocumentos * (cantidadVentanas-alfa+1) , (length(infoHistorica{1,1}) + 1 + length(probCadaClase{1,1}) + length(infoDocumentosParciales{1,1})));
YtrainDMC = zeros(cantidadDocumentos * (cantidadVentanas-alfa+1) , 1);
isForTraining = zeros(cantidadDocumentos, cantidadVentanas);

for i=1:cantidadDocumentos,
    i
    
    for j=alfa:cantidadVentanas,
        j
        
        indice = ((i-1) * (cantidadVentanas-alfa+1) + (j-alfa+1));
        
        isForTraining(i,j) = 1;
        XtrainDMC(indice,:) = [infoHistorica{i,j}, j, probCadaClase{i,j}, infoDocumentosParciales{i,j}];
        if clasePredicha(i,j) == Ytest(i)
            YtrainDMC(indice) = 1;
        else
            YtrainDMC(indice) = -1;
        end       
    end
end

porcentajeTrain = 0.60;

Xtrain = XtrainDMC(1:length(XtrainDMC)*porcentajeTrain, :);
Xtest = XtrainDMC((length(XtrainDMC)*porcentajeTrain)+1 : end, :);
%clear XtrainDMC

Ytrain = YtrainDMC(1:length(YtrainDMC)*porcentajeTrain);
Ytest = YtrainDMC((length(YtrainDMC)*porcentajeTrain)+1 : end);
%clear YtrainDMC


training_data = data(Xtrain, Ytrain);
%clear Xtrain Ytrain

test_data = data(Xtest, Ytest);
%clear Xtest

clop_model = neural;
% clop_model = kridge;
% clop_model = naive;
% clop_model = gentleboost;
% clop_model = j48;

[training_resu, trained_model] = train(clop_model, training_data);
test_resu = test(trained_model, test_data);

error_cost = 0;
cantDoc = ceil(length(Xtest) / cantVen);
cantVen = (cantidadVentanas-alfa+1);

for i=1:cantDoc,
    for j=1:cantVen,
    end
end

error_cost = early_risk_detection_error(sign(test_resu.X), sign(test_resu.X), test_resu.Y, ventana);



[tr_ber, e1, e2, tr_ebar]   = balanced_errate(round(test_resu.X),test_resu.Y);
% [tr_ber, e1, e2, tr_ebar]   = balanced_errate(test_resu.X,test_resu.Y);
fprintf('TEST BER=%5.2f +-%5.2f%%\n', 100*tr_ber, 100*tr_ebar); 


[precision_measure_stop,recall_measure_stop,f1_measure_stop] = eval_prf(test_resu.X,test_resu.Y,1)
[precision_measure_continue,recall_measure_continue,f1_measure_continue] = eval_prf(test_resu.X,test_resu.Y,-1)
% [precision_measure,recall_measure,frv_refull] = eval_prf(test_resu.X,test_resu.Y,1);

[~,AUCv_refull,~, ~] = roc_2(round(test_resu.X), Ytest);
% [~,AUCv_refull,~, ~] = roc_2(test_resu.X, Ytest);
  
accNBMM=(length(find((round(test_resu.X)-test_resu.Y)==0))./length(test_resu.Y)).*100


cd(directorioVariablesWorkspace);

nombreArchivoSalida = [nombreDataset '_DMC_' clop_model.name '.mat'];
save(nombreArchivoSalida, 'training_resu', 'trained_model', 'test_resu', 'precision_measure_stop', 'recall_measure_stop', 'f1_measure_stop', 'precision_measure_continue', 'recall_measure_continue', 'f1_measure_continue');

cd(directorioActual);

disp('El programa finalizo exitosamente');

clear all; close all; clc

% nombreDataset = 'webkb-stemmed';
% nombreDataset = 'r8-all-terms'
% nombreDataset = '20ng-stemmed';
nombreDataset = 'r8-all-terms-clean';

indicesGuiones = strfind(nombreDataset, '-');

datasetEntrenamiento = nombreDataset(1 : indicesGuiones(1)-1);
datasetEntrenamiento = [datasetEntrenamiento '-train-' nombreDataset(indicesGuiones(1)+1 : end) '.txt'];

datasetTest = nombreDataset(1 : indicesGuiones(1)-1);
datasetTest = [datasetTest '-test-' nombreDataset(indicesGuiones(1)+1 : end) '.txt'];

save('configuracion.mat', 'datasetEntrenamiento', 'datasetTest', 'nombreDataset');
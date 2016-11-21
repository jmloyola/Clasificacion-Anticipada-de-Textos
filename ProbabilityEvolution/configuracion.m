clear all; close all; clc

% nombreDataset = 'webkb-stemmed';
% nombreDataset = 'r8-all-terms'
nombreDataset = 'r8-all-terms-clean';
% nombreDataset = '20ng-stemmed';

%% Dataset para probar
% nombreDataset = 'r8-no-short-clean';
% nombreDataset = 'r8-no-stop-clean';
% nombreDataset = 'r8-stemmed';

save('configuracion.mat', 'nombreDataset');

disp('El programa finalizo exitosamente');

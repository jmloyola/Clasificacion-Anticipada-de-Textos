clear all; close all; clc

% nombreDataset = 'webkb-stemmed';
% nombreDataset = 'r8-all-terms'
% nombreDataset = '20ng-stemmed';
% nombreDataset = 'r8-all-terms-clean';

%% Dataset para probar
nombreDataset = 'PRUEBA_r8-no-short-clean';
% nombreDataset = 'PRUEBA_r8-no-stop-clean';
% nombreDataset = 'PRUEBA_r8-stemmed';
% nombreDataset = 'PRUEBA_r52-all-terms-clean';
% nombreDataset = 'PRUEBA_r52-no-short-clean';
% nombreDataset = 'PRUEBA_r52-no-stop-clean';
% nombreDataset = 'PRUEBA_r52-stemmed';

save('configuracion.mat', 'nombreDataset');

disp('El programa finalizo exitosamente');

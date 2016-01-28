clear all; close all; clc

% nombreDataset = 'webkb-stemmed';
% nombreDataset = 'r8-all-terms'
% nombreDataset = '20ng-stemmed';
nombreDataset = 'r8-all-terms-clean';

%% Dataset para probar
% nombreDataset = 'r8-no-short-clean';
% nombreDataset = 'r8-no-stop-clean'; %% VER PORQUE GENERA ERROR AL HACER INDEXADO
% nombreDataset = 'r8-stemmed';
% nombreDataset = 'r52-all-terms-clean'; %% PRECISION 0 WTF!!
% nombreDataset = 'r52-no-short-clean'; %% PRECISION 0 WTF!!
% nombreDataset = 'r52-no-stop-clean'; %% PRECISION 0 WTF!
% nombreDataset = 'r52-stemmed'; %% PRECISION 0 WTF!

save('configuracion.mat', 'nombreDataset');

disp('El programa finalizo exitosamente');

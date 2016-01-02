%% Creo la lista blackWords.
clear all; close all; clc;

directorioActual = pwd;
load configuracion.mat

directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset];
cd(directorioVariablesWorkspace);

nombreDiccionario = [nombreDataset '_Dic.mat'];

load(nombreDiccionario);

blackList = [];
if (strcmp(nombreDataset,'r8-all-terms-cleans'))
    [~,indiceEnElDiccionario]=ismember('the',DicC);
    blackList(1) = indiceEnElDiccionario;
    
    [~,indiceEnElDiccionario]=ismember('and',DicC);
    blackList(2) = indiceEnElDiccionario;
    
    [~,indiceEnElDiccionario]=ismember('for',DicC);
    blackList(3) = indiceEnElDiccionario;
end

nombreBlackWords = [nombreDataset '_BlackWords.mat'];

save(nombreBlackWords, 'blackList');

cd(directorioActual);
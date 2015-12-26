%% Creo la lista blackWords.
clear all; close all; clc;

load R8_DicC.mat

fname = 'r8-train-all-terms-clean.txt'; % Se llama flojera.. jeje despues arreglar.

blackList = [];
if (strcmp(fname,'r8-train-all-terms-clean.txt'))
    [~,indiceEnElDiccionario]=ismember('the',DicC);
    blackList(1) = indiceEnElDiccionario;
    
    [~,indiceEnElDiccionario]=ismember('and',DicC);
    blackList(2) = indiceEnElDiccionario;
    
    [~,indiceEnElDiccionario]=ismember('for',DicC);
    blackList(3) = indiceEnElDiccionario;
end

save R8_BlackWords.mat blackList;
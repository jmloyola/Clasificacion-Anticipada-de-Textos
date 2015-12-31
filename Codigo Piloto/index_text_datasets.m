clear all; close all; clc;


%%% download the files below from the website:
% http://web.ist.utl.pt/acardoso/datasets/
% fname='webkb-train-stemmed.txt';
% fnamete='webkb-test-stemmed.txt';
%fname='r8-train-all-terms.txt'
%fnamete='r8-test-all-terms.txt'
% fname='20ng-train-stemmed.txt';
% fnamete='20ng-test-stemmed.txt';
fname='r8-train-all-terms-clean.txt'
fnamete='r8-test-all-terms-clean.txt'

%% folder where the above files are stored
datadir='C:\Users\Juan Martin\Desktop\Codigo Piloto\';

%% temporal directory to copy files 
tempodir='C:\Users\Juan Martin\Desktop\Codigo Piloto\temp\';
%% copy files to temporal directory with informative filenames
%system(['del ' tempodir '*.txt'])
delete([tempodir '*.txt']);

% trabaja con el archivo de entrenamiento
S=file2str([datadir fname]);

% Crea los archivos temporales, donde cada uno es un documento que se le ha
% quitado la clase. El nombre es una combinacion de la clase, la fecha de
% indexacion y un numero random
for i=1:length(S),
    idx=strfind(S{i},sprintf('\t')); % En la variable idx almaceno las posiciones en el documento 'i' que encuentro un caracter '\t'
    clax{i}=S{i}(1:idx(1)-1); % En la variable clax (en la posicion 'i') guardo la clase a la que pertenece el documento de la linea 'i'
    filesname{i}=[strrep(strrep(datestr(now),':',''),' ','') '_' num2str(rand) '.txt']; % Forma parte del nombre de los archivos temporales que va creando. Inserta la fecha actual y un numero random, quitando los espacios en blanco y separando la fecha del numero con un caracter '_'
    str2file({S{i}(idx+1:end)},[tempodir clax{i} '_' filesname{i}]); % Forma el path y el nombre completo de los archivos temporales.        
end

dc=i+1;

% trabaja con el archivo de test
S=file2str([datadir fnamete]); % Notar que aqui NO se anexa a lo que ya tenia S, los valores viejos se pierden.

for i=1:length(S),
	% >>> VER <<<
	% Notar que en la iteracion no se aumenta la variable dc (se sobrescribe esa posicion), pero esto no genera problema. Antes de sobrescribir la información la utiliza para dar nombre al archivo.
    % Notar que de igual forma que se hace con la posicion dc, se puede hacer con todos los documentos. se podria tener una unica posicion.
    idx=strfind(S{i},sprintf('\t'));
    clax{dc}=S{i}(1:idx(1)-1);
    filesname{dc}=[strrep(strrep(datestr(now),':',''),' ','') '_' num2str(rand) 'test.txt'];
    str2file({S{i}(idx+1:end)},[tempodir clax{dc} '_' filesname{dc}]);        
end

clear S clax;

%%% indexing using the TMG toolbox
OPTIONS.min_length=3;
OPTIONS.min_local_freq=1;
OPTIONS.min_global_freq=1;
OPTIONS.delimiter='none_delimiter';
OPTIONS.line_delimiter=0;
OPTIONS.stemming=0;
OPTIONS.global_weight='x';
OPTIONS.local_weight='t';
OPTIONS.normalization='x';

[B, DICTIONARY, GLOBAL_WEIGHTS, NORMALIZATION_FACTORS, ...
        WORDS_PER_DOC,TITLES, FILES, UPDATE_STRUCT] = tmg([tempodir],OPTIONS);        


for i=1:size(DICTIONARY,1),
    DicC{i}=strrep(DICTIONARY(i,:),' ','');
    % NOTA: Hace esto ya que el diccionario es un arreglo donde se
    % almacena cada palabra que aparece en los documentos. Cada palabra es
    % guardada en un arreglo de tamanio igual a 24. Asi cuando la palabra
    % tiene longitud menor a 24 se completa con espacios en blanco ' '. Por
    % ello se hace el strrep (quitando estos espacios en blanco).
end
clear DICTIONARY;

% Recordar que la matriz B es la que tiene para cada documento la medida tf
% de cada termino. Las filas representan terminos y las columnas
% documentos.
% Asi size(B,2) es la cantidad de documentos.
% max(B)es un vector de tama�o la cantidad de documentos que contiene el
% termino que mayor valor de cada documento.
seqinf=sparse(size(B,2),max(max(B)));


% >>> VER <<< 
% Se supone que el tamanio de titles es igual a la cantidad
% de documentos de entrenamiento mas la cantidad de documentos de test?
% porque al ejecutarlo con el dataset r8 no da exactamente igual. por
% ejemplo tengo 5485 documentos de entrenamiento, 2189 de test (cuya suma
% es 7674) pero la dimension de titles es 7669.

%% get sequential data
for i=1:length(TITLES),
    cad=TITLES{i};
    idx1=strfind(cad,'/');
    idx2=strfind(cad,'_');
    classex{i}=cad(idx1(1)+1:idx2(1)-1);
    istraining(i)=isempty(strfind(cad,'test'));    
    idx0=strfind(cad,'.1');
    cad=cad(idx0(1)+2:end);
    idx=strfind(cad,' ');
    
	% >>> VER <<<
	% Controlar que efectivamente elimina los espacios en blanco!!!!
	% Me parece que como lo hace aqui evita justamente reemplazar los espacios.
	
	% seqdoc y seqdocCopia tienen exactamente lo mismo, pero en el segundo
    % no se hace todo el trabajo para 'quitar' los espacios en blanco.
    for j=1:length(idx), % >>> VER <<< Controlar que vea todos los terminos! En la versión inicial llegaba hasta j=1:length(idx)-1
        if j==1,
            seqdoc{j}=strrep(cad(3:idx(1)-1),' ',''); % Notar que en lugar de comenzar desde cad(1:) se comienza desde cad(3:), esto se debe a que en las primeras dos posiciones se encuentra un tab (notar que la función strrep tampoco lo elimina).
            %seqdocCopia{j}=cad(3:idx(1)-1);
        else
            seqdoc{j}=strrep(cad(idx(j-1)+1:idx(j)-1),' ','');
            %seqdocCopia{j}=cad(idx(j-1)+1:idx(j)-1);
        end
    end
	
    seqdoc{j+1}=strrep(cad(idx(end)+1:end),' ','');
    %seqdocCopia{j+1}=cad(idx(end)+1:end);
	%%% Comento seqdocCopia para ahorrar espacio
    
    [aa,bb]=ismember(seqdoc,DicC);
	% >>> VER <<<
    % Analizar bien como es la variable DicC.
    % Como esta ahora, �no ocurre que toda palabra del documento estan en
    % el DicC? Asi aa es un arreglo con todos unos.
    % No sucede esto me parece porque la estructura tiene todos los terminos de los documentos,
    % mientras que el diccionario tiene todos los términos que tienen 3 o mas caracteres.

    % En seqinf almacena por cada palabra que aparece en el documento que
    % se encuentra en el DicC en que posicion de DicC esta.
    seqinf(i,1:length(find(aa)))=bb(find(aa));
    
    clear seqdoc;
end

save 'R8_DicC.mat' 'DicC'
clear DicC

X=B';
[a,b]=ismember(classex,unique(classex));
Y=b';

clear B GLOBAL_WEIGHTS NORMALIZATION_FACTORS WORDS_PER_DOC FILES UPDATE_STRUCT OPTIONS;


nX=sparse(size(X,1),size(X,2));
% En esta iteracion genera nuevamente la matriz con las frecuencias de los
% terminos para cada documento.
for i=1:size(X), % Itera sobre la cantidad de documentos (cantidad de filas de X)
    ofin=find(seqinf(i,:)~=0); % Busca los elementos en seqinf(i,:) distintos de cero. Se podria habe usado find(seqinf(i,:))
    for j=1:length(ofin),
        nX(i,seqinf(i,ofin(j)))=nX(i,seqinf(i,ofin(j)))+1;
    end          
end

% >>> VER <<<
% A que se debe la diferencia entre X y nX!!


Xtrain=X(find(istraining==1),:);
Ytrain=Y(find(istraining==1));
Xtest=X(find(istraining==0),:);
Ytest=Y(find(istraining==0));

sTrain=seqinf(find(istraining==1),:);
sTest=seqinf(find(istraining==0),:);

nXtrain=nX(find(istraining==1),:);
nYtrain=Y(find(istraining==1));
nXtest=nX(find(istraining==0),:);
nYtest=Y(find(istraining==0));

save R8_seq_emnlp_FullVoc.mat Xtrain Xtest Ytrain Ytest seqinf sTest sTrain
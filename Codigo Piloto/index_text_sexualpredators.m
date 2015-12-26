clear all; close all; clc;

%% data directory for training conversations
datadir='C:\HugoJairWork\EarlyClassification\sexpred\esaudata\TRAINING\TRAINING\Conversaciones_Filtradas_SoloTexto\';
%% id of predator converstaions in training set
f_pos_train='C:\HugoJairWork\EarlyClassification\sexpred\esaudata\TRAINING\TRAINING\Conversaciones_Filtradas_ID_Sospechosas\id_suspicious_chats.txt';

pos_train=file2str(f_pos_train);
for i=1:length(pos_train),
    pos_train{i}=[pos_train{i} '.txt'];
end

%% get character ngrams
kval=3;
tempodir='C:\HugoJairWork\EarlyClassification\wwtext\text\tempo\';
system(['del ' tempodir '*.txt']);
nomecl={'1_first','2_second','3_third'};
S=dir([datadir]);S=S(3:end);
for i=1:length(S),
    TF=file2str([datadir S(i).name ]);
    an='';
    for h=1:length(TF),
        an=[an ' ' TF{h}];
    end
    clear TF;    
    % % % % % % % % Extract n-grams at the character level
    cad=strrep(an,' ','&');
    ncad='';
    ii=1;
    ij=kval;
    tflag=1;
    while tflag,
        if ij+1<=length(cad)
            ncad=[ncad ' ' cad(ii:ij) ' '];
            ii=ii+1;ij=ij+1;
        else tflag=0;
        end
    end
    if ismember(S(i).name,pos_train),
        str2file({ncad},[tempodir S(i).name '_positives_train.txt']);
    else
        str2file({ncad},[tempodir S(i).name '_negatives_train.txt']);
    end
            
    clear ncad;
end

%% data directory for test conversations
datadir='C:\HugoJairWork\EarlyClassification\sexpred\esaudata\TEST\TEST\Conversaciones_Filtradas_SoloTexto\';
%% id of predator converstaions in test set
f_pos_test='C:\HugoJairWork\EarlyClassification\sexpred\esaudata\TEST\TEST\Conversaciones_Filtradas_ID_Sospechosas\id_suspicious_chats.txt';
pos_test=file2str(f_pos_test);
for i=1:length(pos_test),
    pos_test{i}=[pos_test{i} '.txt'];
end
%% extract character ngrams
S=dir([datadir]);S=S(3:end);
for i=1:length(S),
    TF=file2str([datadir S(i).name ]);
    an='';
    for h=1:length(TF),
        an=[an ' ' TF{h}];
    end
    clear TF;    
        
    % % % % % % % % Extract n-grams at the character level
    cad=strrep(an,' ','&');
    ncad='';
    ii=1;
    ij=kval;
    tflag=1;
    while tflag,
        if ij+1<=length(cad)
            ncad=[ncad ' ' cad(ii:ij) ' '];
            ii=ii+1;ij=ij+1;
        else tflag=0;
        end
    end
    if ismember(S(i).name,pos_test),
        str2file({ncad},[tempodir S(i).name '_positives_test.txt']);
    else
        str2file({ncad},[tempodir S(i).name '_negatives_test.txt']);
    end
    clear ncad;
end

%% index conversations with tmg toolbox

OPTIONS.min_length=1;
OPTIONS.min_local_freq=1;
OPTIONS.min_global_freq=30;
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
end
clear DICTIONARY;
%% get sequential info, training test files
seqinf=sparse(size(B,2),max(max(B)));
for i=1:length(TITLES),
    i
    cad=TITLES{i};
    classex(i)=isempty(strfind(cad,'negatives'));
    traintest_(i)=isempty(strfind(cad,'test'));
    idx=strfind(cad,' ');    
    for j=1:length(idx)-1,
        if j==1,
            seqdoc{j}=strrep(cad(1:idx(1)-1),' ','');
        else
            seqdoc{j}=strrep(cad(idx(j)+1:idx(j+1)-1),' ','');
        end        
    end
    seqdoc{j}=strrep(cad(idx(end)+1:end),' ','');
    [aa,bb]=ismember(seqdoc,DicC);
    seqinf(i,1:length(find(aa)))=bb(find(aa));
    clear seqdoc;
end

X=B';
Y=double(classex)';
Y(find(classex==0))=-1;
sX=seqinf;


sTrain=seqinf(find(traintest_==1),:);
sTest=seqinf(find(traintest_==0),:);
Xtrain=X(find(traintest_==1),:);
Xtest=X(find(traintest_==0),:);
Ytrain=Y(find(traintest_==1));
Ytest=Y(find(traintest_==0));

save Sexpred_Indexed.mat Xtrain Xtest Ytrain Ytest seqinf sTest sTrain

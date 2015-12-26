clear all; close all; clc;

%% add CLOP to the path
%%%%% get it from: http://www.clopinet.com/CLOP/
% ppath=pwd;
% cd C:\CLOP;
% use_spider_clop;
% cmd=['cd ''' ppath ''''];
% eval(cmd);

clop_model=(kridge);
use_signed_output=0;

%% load one data file (uncomment one of the load-lines below)
%%%%% Reuters-8 reduced vocabulary
% load R8Cachopo_seq_emnlp_redVoc.mat
%%%%% Reuters-8 full vocabulary
load R8_seq_emnlp_FullVoc.mat
%%%%% WebKB reduced vocabulary
% load WebKB_seq_emnlp_redVoc.mat
%%%%% WebKB full vocabulary
% load WebKB_seq_emnlp_FullVoc.mat
%%%%% 20NewsGropup reduced vocabulary
% load 20NWs_seq_emnlp_redVoc.mat

%% get classes 
classex=unique(Ytrain);
Yones=-ones(size(Ytrain,1),length(classex));
for i=1:length(classex),
    Yones(find(Ytrain==classex(i)),i)=1;
end
YTones=-ones(size(Ytest,1),length(classex));
for i=1:length(classex),
    YTones(find(Ytest==classex(i)),i)=1;
end

%% get tfidf weigthing scheme
nozTr=(Xtrain~=0);
nozTe=(Xtest~=0);
idff=(log(1+ (size(Xtrain,1)./(sum(nozTr)+1))));
mXtrain=Xtrain.*repmat(idff,size(Xtrain,1),1);
mXtest=Xtest.*repmat(idff,size(Xtest,1),1);
for i=1:size(Xtrain,1), 
    sXtrain(i,:)=mXtrain(i,:)./sqrt(sum(mXtrain(i,:).^2)); 
end
for i=1:size(Xtest,1), 
    sXtest(i,:)=mXtest(i,:)./sqrt(sum(mXtest(i,:).^2)); 
end

%% train one-vs-rest classifiers
for i=1:length(classex),
    [qa,qb]=train(clop_model,data(Xtrain,Yones(:,i)));
    modelq{i}=qb;
 
    [qa,qb]=train(clop_model,data(sXtrain,Yones(:,i)));
    modelqs{i}=qb;

    
end


%% test the one-vs-rest models
for g=1:length(classex),
        
    cute=test(modelq{g},data(Xtest));
    xxcc.X(:,g)=cute.X;
    
    cutes=test(modelqs{g},data(sXtest));
    xxccs.X(:,g)=cutes.X;
    
    [prv_refull(g),rrv_refull(g),frv_refull(g)] = eval_prf(xxcc.X(:,g),YTones(:,g),1);
    [~,AUCv_refull(g),~, ~] = roc_2(xxcc.X(:,g), YTones(:,g));                   
    
    [prv_refulls(g),rrv_refulls(g),frv_refulls(g)] = eval_prf(xxccs.X(:,g),YTones(:,g),1);
    [~,AUCv_refulls(g),~, ~] = roc_2(xxccs.X(:,g), YTones(:,g));                   
end    
%%%%%% clop_model - TF performance
[vl,ivl]=max(xxcc.X');
acurefull=length(find((ivl'-Ytest)==0))./length(ivl)

%%%%%% clop_model - TFIDF performance
[vls,ivls]=max(xxccs.X');
acurefulls=length(find((ivls'-Ytest)==0))./length(ivls)

close all;

%% train Naive Bayes classifier
[NB] = MNNaiveBayes(Xtrain,Ytrain,1,[]);

%% Perform sequential/incremental predictions
retains=0.01:0.05:0.99;
retains(end)=1;
for j=1:length(retains),
    j
    close all;
    rXtest=sparse(size(Xtest,1),size(Xtest,2));
    %% simulate a reduced attribute set
    for i=1:size(Xtest,1),        
        noz=length(find(sTest(i,:)~=0));
        ntermssf=round((noz).*retains(j));
        myox=1;wdix=1;
        freqtsof=sparse(1,size(Xtest,2));
        while myox<=ntermssf ,
            if sTest(i,wdix)~=0,
                freqtsof(sTest(i,wdix))=freqtsof(sTest(i,wdix))+1;
                myox=myox+1;
            end
            wdix=wdix+1;
        end        
        rXtest(i,:)=freqtsof;
    end
    Xtestv=rXtest;
    %% test the models
    for g=1:length(classex),               
        %%%% tf model
        [qc]=test(modelq{g},data(rXtest));
        TeoPq(:,g)=qc.X;
        [prvq(g,j),rrvq(g,j),frvq(g,j)] = eval_prf(qc.X,YTones(:,g),1);
        [~,AUCvq(g,j),~, ~] = roc_2(qc.X, YTones(:,g));           
        TeoN1Pq(:,g)=(TeoPq(:,g)-min(TeoPq(:,g)))./(max(TeoPq(:,g))-min(TeoPq(:,g)));            
        
        %%%% tfidf model
        clear srXtest;
        srXtest=rXtest.*repmat(idff,size(rXtest,1),1);
        nozes=sum(srXtest,2);
        for i=1:size(rXtest,1), 
            if nozes(i)~=0,
                srXtest(i,:)=rXtest(i,:)./sqrt(sum(rXtest(i,:).^2)); 
            end
        end        
        [qc]=test(modelqs{g},data(srXtest));
        TeoPqs(:,g)=qc.X;
        [prvqs(g,j),rrvqs(g,j),frvqs(g,j)] = eval_prf(qc.X,YTones(:,g),1);
        [~,AUCvqs(g,j),~, ~] = roc_2(qc.X, YTones(:,g));           
        TeoN1Pqs(:,g)=(TeoPqs(:,g)-min(TeoPqs(:,g)))./(max(TeoPqs(:,g))-min(TeoPqs(:,g)));            
    end    
    close all;    
    %%% accuracy estimates TF and TFIDF    
    [~,predicqs]=max(TeoPqs');
    predicqs=predicqs';
    
    acc_partqs(j)=(length(find((predicqs-Ytest)==0))./length(Ytest)).*100;
    predictionss(j).Qallpreds=predicqs;
    
    
    [~,predicq]=max(TeoPq');
    predicq=predicq';
    
    acc_partq(j)=(length(find((predicq-Ytest)==0))./length(Ytest)).*100;
    predictions(j).Qallpreds=predicq;        
    
    clear pred predic
    
    %% classify with Naive Bayes and estimate performance
    [NB0] = MNNaiveBayes(Xtestv,[],0,NB);
    pred=NB0.pred;
    clear pr rr fr
    for i=1:length(classex),
        predtem=-ones(size(Ytest));
        predtem(find(pred==classex(i)))=1;
        [prnbmm(i),rrnbmm(i),frnbmm(i)] = eval_prf(predtem,YTones(:,i),1);
    end
    efes(j).NBMM=[mean(prnbmm),mean(rrnbmm),mean(frnbmm)];
    accNBMM(j)=(length(find((pred-Ytest)==0))./length(Ytest)).*100;
    predictions(j).NBMM=pred;
    lasefesnbm(j)=mean(frnbmm);
    
    clear pred;
    close all; figure;
    plot((retains(1:j)).*100,[[mean(frvq);mean(frvqs)];lasefesnbm]','LineWidth',2,'MarkerSize',10); %% plots f_1 measure
%     plot((retains(1:j)).*100,[acc_partq;acc_partqs;accNBMM]','LineWidth',2,'MarkerSize',10); %% plots accuracy
    legend({'SVM-TF','SVM-TFIDF','NBM'});
    set(gca,'FontSize',14);
    xlabel('Percentage of information');
%     ylabel('Accuracy');
    ylabel('Macro f_1 measure'); 
    set(gcf,'Color','w');
    grid;
    gcf;box;

    pause(1);   
end


clear all; close all; clc;

%% add CLOP to the matlab path
% ppath=pwd;
% cd C:\CLOP;
% use_spider_clop;
% cmd=['cd ''' ppath ''''];
% eval(cmd);

%% parameters for the classification model
clop_model=(kridge);
use_signed_output=0;

%% load indexed data
load sexpred_esau_part.mat

%% get classes and priors
classex=unique(Ytrain);

%% Get tfidf scheme
nozTr=(Xtrain~=0);
idff=(log(1+ (size(Xtrain,1)./(sum(nozTr)+1))));
mXtrain=Xtrain.*repmat(idff,size(Xtrain,1),1);
mXtest=Xtest.*repmat(idff,size(Xtest,1),1);
for i=1:size(Xtrain,1), 
    sXtrain(i,:)=mXtrain(i,:)./sqrt(sum(mXtrain(i,:).^2)); 
end
for i=1:size(Xtest,1), 
    sXtest(i,:)=mXtest(i,:)./sqrt(sum(mXtest(i,:).^2)); 
end
sXtrain(find(isnan(sXtrain)))=0;
sXtest(find(isnan(sXtest)))=0;
%% train clop_model on tfidf data and evaluate performance
[qa,qb]=train(clop_model,data(sXtrain,Ytrain));
modelqs{1}=qb;
[qqc]=test(qb,data(sXtest));
Teofulls(:,1)=qqc.X;
[prfulls(1),rrfulls(1),frfulls(1)] = eval_prf(qqc.X,Ytest,1);
[~,AUCfulls(1),~, ~] = roc_2(qqc.X, Ytest);
acurefulls=accuracy_two_class(qqc.X,Ytest);

%% train and evaluate performance of clop_model on tf weighted data
[qa,qb]=train(clop_model,data(Xtrain,Ytrain));
modelq{1}=qb;
[qqc]=test(qb,data(Xtest));
Teofull(:,1)=qqc.X;
[prfull(1),rrfull(1),frfull(1)] = eval_prf(qqc.X,Ytest,1);
[~,AUCfull(1),~, ~] = roc_2(qqc.X, Ytest);
acurefull=accuracy_two_class(qqc.X,Ytest);


    
%% train Naive Bayes Multinomial
[NB] = MNNaiveBayes(Xtrain,Ytrain,1,[]);

%% start sequential incremental classification, you define the granularity
% retains=0.01:0.01:0.99;  %%% 1% splits
retains=0.01:0.05:0.99;    %%% 5% splits
for j=1:length(retains),
    j
    close all;
    %% simulate a reduced attribute set    
    rXtest=sparse(size(Xtest,1),size(Xtest,2));
    for i=1:size(Xtest,1),
        noz=setdiff(sTest(i,:),0);        
        ntermssf=round(length(noz).*retains(j));
        myox=1; wdix=1;
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
    
    
    for g=1:1,
               
        %% TF clop_model evaluation
        [qc]=test(modelq{g},data(rXtest));
        TeoPq(:,g)=qc.X;
        [prvq(g,j),rrvq(g,j),frvq(g,j)] = eval_prf(qc.X,Ytest,1);
        [~,AUCvq(g,j),~, ~] = roc_2(qc.X, Ytest);           
        acc_partq(j)=(accuracy_two_class(qc.X,Ytest)).*100;
        
        %% TFIDF clop_model evaluation
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
        [prvqs(g,j),rrvqs(g,j),frvqs(g,j)] = eval_prf(qc.X,Ytest,1);
        [~,AUCvqs(g,j),~, ~] = roc_2(qc.X, Ytest);           
        acc_partqs(j)=(accuracy_two_class(qc.X,Ytest)).*100;        
    end    
    
    efes(j).KRIDGE=[(prvq(j)),(rrvq(j)),(frvq(j))];
    AUCs(j).KRIDGE=AUCvq(j);
    
    efes(j).NormSVM=[mean(prvqs(j)),mean(rrvqs(j)),mean(frvqs(j))];
          
    
    %% evaluate Naive Bayes
    [NB0] = MNNaiveBayes(Xtestv,[],0,NB);
    pred=NB0.pred;
    pred(find(pred==1))=-1;
    pred(find(pred==2))=1;
    [prnbmm(j),rrnbmm(j),frnbmm(j)] = eval_prf(pred,Ytest,1);
    efes(j).NBMM=[(prnbmm(j)),mean(rrnbmm(j)),mean(frnbmm(j))];
    accNBMM(j)=(length(find((pred-Ytest)==0))./length(Ytest)).*100;
    predictions(j).NBMM=pred;    
    clear pred;
    close all; figure;
    %%% optinally plot accuracy
%     plot((tretains(1:j)).*100,[acc_partq;acc_partqs;accNBMM]','LineWidth',2,'MarkerSize',10);
    plot((retains(1:j)).*100,[[(frvq);(frvqs)];frnbmm]','LineWidth',2,'MarkerSize',10);
    legend({'SVM-TF','SVM-TFIDF','NBM'});
    set(gca,'FontSize',14);
    xlabel('Percentage of information');
    ylabel('F_1 measure');
    set(gcf,'Color','w');
    grid;
    gcf;box;



    pause(1);
    

end

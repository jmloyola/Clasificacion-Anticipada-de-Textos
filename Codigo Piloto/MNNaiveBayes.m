function [NB] = MNNaiveBayes(X,Y,training,NB) %%% PORQUE USA EL MISMO NOMBRE PARA UN PARAMETRO Y PARA LA SALIDA??? Usa pasaje por valor por default matlab. Así cuando utiliza NB como valor, esta usando el parametro. Cuando asigna un valor a NB lo asigna a la salida de la funcion.
[ndocs,nterms]=size(X);

if training,    
    classex=unique(Y);
    nclassex=length(classex);
    P=zeros(nterms,nclassex);
    for i=1:nclassex,
        ofin=find(Y==classex(i)); % Calcula cuales son los documentos cada clase.
        prior(i)=length(ofin)./ndocs; % Calcula la probabilidad a priori de cada clase. 
        Fncs=sum(X(ofin,:)); % Para cada clase calcula la cantidad de repeticiones de cada termino.
        Fncden=sum(Fncs); % Para cada clase calcula la cantidad total de terminos.
        
        P(:,i)=((1+ Fncs)./(ndocs + Fncden))';    
        
%         P(:,i)=((1+ Fncs)./(ndocs + Fncden))';    
    end

    NB.prior=prior;
%     NB.prior=[0.5,0.5];
    NB.P=P;

else
    nclassex=length(NB.prior);            
    for j=1:ndocs,
        for i=1:nclassex,
            ofin=find(X(j,:)~=0);
            
            Pr(j,i)=(log(NB.prior(i)))+sum(log((NB.P(ofin,i)').^X(j,ofin)));
            
%             Pr(j,i)=(log(NB.prior(i)))+sum(log((NB.P(:,i)').^X(j,:)));
            
%             Pr(j,i)=(NB.prior(i)).*(prod((NB.P(ofin,i)').^X(j,ofin)));


%             Pr(j,i)=(factorial(length(ofin))).*(NB.prior(i)).*(prod(((NB.P(:,i)').^X(j,:))./factorial(X(j,:))));
            
%             nofin=setdiff(1:nterms,ofin);
%             Pr(j,i)=(NB.prior(i)).*(prod(((NB.P(ofin,i)').^X(j,ofin))./factorial(X(j,ofin)))).*(factorial(sum(X(j,ofin))));
        end
%         Prn(j,:)=Pr(j,:)./sum(NB.prior.*Pr(j,:));
%         Prn2(j,:)=Pr(j,:)./sum(Pr(j,:));
    end                
    
    NB.Pr=Pr;
%     NB.Prn=Prn;
%     NB.Prn2=Prn2;
    [~,NB.pred]=max(Pr');
    NB.pred=NB.pred';
end

end

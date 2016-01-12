clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;

%% Lugar donde se encuentran los .mat
directorioVariablesWorkspace = 'C:\Users\Juan Martin\Documents\GitHub\Clasificacion-Anticipada-de-Textos\Codigo Piloto\Variables del Workspace\';

pathMatrices = [directorioVariablesWorkspace nombreDataset '_Matrices.mat'];
load(pathMatrices);

pathBlackWords = [directorioVariablesWorkspace nombreDataset '_BlackWords.mat'];
load(pathBlackWords, 'blackList');

pathTerminosPorClase = [directorioVariablesWorkspace nombreDataset '_TerminosPorClase.mat'];
load(pathTerminosPorClase, 'indicesTerminosMasFrecPorClase');

classex=unique(Ytrain);

YTones=-ones(size(Ytest,1),length(classex));
for i=1:length(classex),
    YTones(find(Ytest==classex(i)),i)=1;
end


%% Cargo el modelo entrenado
pathModeloEntrenamiento = [directorioVariablesWorkspace nombreDataset '_ModeloEntrenado.mat'];
load(pathModeloEntrenamiento, 'NB');
%[NB] = MNNaiveBayes(Xtrain,Ytrain,1,[]);

%% Realizo las predicciones incrementales (ventana a ventana)
tamanioVentana = 5;
ventanas = 1:tamanioVentana:36;

infoDocumentosParciales = cell(size(Xtest,1), length(ventanas));
indiceVentanas = zeros(size(Xtest,1), length(ventanas));
probCadaClase = cell(size(Xtest,1), length(ventanas));


for j=1:length(ventanas),
    j
    close all;
    rXtest=sparse(size(Xtest,1),size(Xtest,2));
    %% Simulo el conjunto de atributos disminuidos
    for i=1:size(Xtest,1),        
        noz=length(find(sTest(i,:)~=0));
        if (noz <= ventanas(j))
            ntermssf = noz;
        else
            ntermssf = ventanas(j);
        end
        
        indiceVentanas(i,j) = ntermssf;
        
        doc = full(sTest(i,1:ntermssf));
        documentoParcial = doc(find(doc));
        [npTotal, npDistintas, npBlackList, npMasFrecuentesCadaClase] = informacionDocumentosParciales(documentoParcial, blackList, indicesTerminosMasFrecPorClase);
        
        infoDocumentosParciales{i,j} = [npTotal, npDistintas, npBlackList, npMasFrecuentesCadaClase];
        
        myox=1;
        wdix=1;
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
    
    %% Clasifico con Naive Bayes y estimo la performance 
    [NB0] = MNNaiveBayes(Xtestv,[],0,NB);
    
    for i=1:size(Xtest,1)
        probCadaClase{i,j} = NB0.Pr(i,:);
    end    
    
    pred=NB0.pred;
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
    close all; 
    f = figure;
    %plot((ventanas(1:j)),lasefesnbm','LineWidth',2,'MarkerSize',10); %% plots f_1 measure
	%plot((ventanas(1:j)),accNBMM','LineWidth',2,'MarkerSize',10); %% plots accuracy
    plot((ventanas(1:j)),[lasefesnbm; accNBMM]','LineWidth',2,'MarkerSize',10);
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    titulo = {'Clasificacion Anticipada en el Dataset'; nombreDataset};
    title(titulo);
    legend('Macro F1', 'Accuracy', 'Location', 'southeast');
    set(gca,'FontSize',14);
    xlabel('Cantidad de Terminos Leidos');
	%ylabel('Accuracy');
    %ylabel('Macro f_1 measure');
    ylabel('Porcentaje');
    set(gcf,'Color','w');
    grid;
    gcf;
    box;

    pause(1);   
end

%% Creo un directorio donde almacenar las distintas figuras.
directorioFiguras = [directorioActual '\Figuras\' nombreDataset];
% Controlo si existe el directorio. Si no existe creo la carpeta.
if (exist(directorioFiguras, 'dir') ~= 7)
    mkdir(directorioFiguras);
end
cd(directorioFiguras);

% Controlo si existen los directorios. Si no existen los creo.
if (exist([directorioFiguras '\Fig'], 'dir') ~= 7) % La funcion exist() retorna cero si no existe archivo o directorio con dicho nombre. Si existe directorio con dicho nombre retorna 7. (Notar que para otro tipos como archivos, clases, etc existen otros valores de retorno).
    mkdir('Fig');
end
if (exist([directorioFiguras '\Svg'], 'dir') ~= 7)
    mkdir('Svg');
end
if (exist([directorioFiguras '\Eps'], 'dir') ~= 7)
    mkdir('Eps');
end
if (exist([directorioFiguras '\Png'], 'dir') ~= 7)
    mkdir('Png');
end

% Guardo la figura en disco.
nombreFiguraFig = [directorioFiguras '\Fig\' nombreDataset '_MacroF1Precision_Ventana' num2str(tamanioVentana)];
nombreFiguraSvg = [directorioFiguras '\Svg\' nombreDataset '_MacroF1Precision_Ventana' num2str(tamanioVentana)];
nombreFiguraEps = [directorioFiguras '\Eps\' nombreDataset '_MacroF1Precision_Ventana' num2str(tamanioVentana)];
nombreFiguraPng = [directorioFiguras '\Png\' nombreDataset '_MacroF1Precision_Ventana' num2str(tamanioVentana)];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc'); % Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


cd(directorioActual);

disp('El programa finalizo exitosamente');

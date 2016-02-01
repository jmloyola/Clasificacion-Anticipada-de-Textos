clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;

%% Lugar donde se encuentran los .mat
directorioVariablesWorkspace = 'C:\Users\Juan Martin\Documents\GitHub\Clasificacion-Anticipada-de-Textos\Codigo Piloto\Variables del Workspace\';

pathMatrices = [directorioVariablesWorkspace nombreDataset '\' nombreDataset '_Matrices.mat'];
load(pathMatrices);

pathTerminosPorClase = [directorioVariablesWorkspace nombreDataset '\' nombreDataset '_TerminosPorClase.mat'];
load(pathTerminosPorClase, 'indicesTerminosMasFrecPorClase');

pathInformacionParcial = [directorioVariablesWorkspace nombreDataset '\' nombreDataset '_InfoDocumentosParciales.mat'];
load(pathInformacionParcial, 'infoDocumentosParciales');

classex=unique(Ytrain);

YTones=-ones(size(Ytest,1),length(classex));
for i=1:length(classex),
    YTones(find(Ytest==classex(i)),i)=1;
end


%% Cargo el modelo entrenado
pathModeloEntrenamiento = [directorioVariablesWorkspace nombreDataset '\' nombreDataset '_ModeloEntrenado.mat'];
load(pathModeloEntrenamiento, 'NB');

%% Realizo las predicciones incrementales (ventana a ventana)
tamanioVentana = 1;
valorInicial = 1;
valorFinal = 35
ventanas = valorInicial:tamanioVentana:valorFinal;

%% claseActual = 1
%% DocumentosClase = sTest(find(Ytest==claseActual), :);
%% rXtest = zeros(size(DocumentosClase,1), size(Xtest,2));

for j=1:length(ventanas),
    j
    close all;
    rXtest = sparse(size(Xtest,1), size(Xtest,2));
    %% Simulo el conjunto de atributos disminuidos
    
    for i=1:size(Xtest,1),
        documento = full(sTest(i,:));
        documento = documento(find(documento));
        
        noz=length(documento);
        if (noz <= ventanas(j))
            ntermssf = noz;
        else
            ntermssf = ventanas(j);
        end
        
        documentoParcial = documento(1:ntermssf);
        
        myox = 1;
        wdix = 1;
        freqtsof = sparse(1, size(Xtest,2));
        while myox <= ntermssf,
            if documentoParcial(wdix) ~= 0,
                freqtsof(documentoParcial(wdix)) = freqtsof(documentoParcial(wdix)) + 1;
                myox = myox + 1;
            end
            wdix = wdix+1;
        end
        rXtest(i,:) = freqtsof;
    end
    
    Xtestv=rXtest;
    
    %% Clasifico con Naive Bayes y estimo la performance 
    [NB0] = MNNaiveBayes(Xtestv,[],0,NB);
    
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
    f = figure('units','normalized','position',[.01 .01 .99 .99]);
    %plot((ventanas(1:j)),lasefesnbm','LineWidth',2,'MarkerSize',10); %% plots f_1 measure
	%plot((ventanas(1:j)),accNBMM','LineWidth',2,'MarkerSize',10); %% plots accuracy
    subplot(2,2,1);
    plot((ventanas(1:j)),[lasefesnbm; accNBMM]','LineWidth',1,'MarkerSize',8);
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    %% titulo = {'Clasificacion Anticipada'; char(strcat({'Clase: '}, nombreClases(claseActual))); nombreDataset};
    titulo = {'Clasificacion Anticipada'; nombreDataset};
    title(titulo);
    %legend('Macro F1', 'Accuracy', 'Location', 'southeast');
    legend('Macro F1', 'Accuracy','Location','eastoutside','Orientation','vertical');
    set(gca,'FontSize',11);
    xlabel('Cantidad de Terminos Leidos');
	%ylabel('Accuracy'); 
    %ylabel('Macro f_1 measure');
    ylabel('Porcentaje');
    set(gcf,'Color','w');
    grid;
    gcf;
    box;
    
    sumaCantTerminos = zeros(1,length(classex));
    porcentajeTerminos = zeros(1,length(classex));
    sumaPorcentajesTerminos = zeros(1,length(classex));
    for x=1:length(classex)
        documentosClase = find(Ytest==i);
        for y=1:length(documentosClase)
            sumaCantTerminos(x) = sumaCantTerminos(x) + infoDocumentosParciales{documentosClase(y),j}(x+3); % Sumo tres a la posicion de infoDocumentosParciales para obtener los valores de cantidad terminos más importantes de cada clase
            porcentajeTerminos(x) = infoDocumentosParciales{documentosClase(y),j}(x+3) / infoDocumentosParciales{documentosClase(y),j}(1); % La primer posicion de infoDocumentosParciales{documentosClase(y),j} tiene la cantidad de palabras.
            sumaPorcentajesTerminos(x) = sumaPorcentajesTerminos(x) + porcentajeTerminos(x);
        end
        sumaCantTerminos(x) = sumaCantTerminos(x) / length(documentosClase);
        sumaPorcentajesTerminos(x) = sumaPorcentajesTerminos(x) / length(documentosClase);
    end
    
    mediaSumaCantTerminos(j) = mean(sumaCantTerminos);
    mediaSumaPorcentajesTerminos(j) = mean(sumaPorcentajesTerminos);
    
    %% Grafico el numero de terminos mas importantes de la clase indicada de cada documento.
    subplot(2,2,2);
    plot((ventanas(1:j)),mediaSumaCantTerminos,'LineWidth',1,'MarkerSize',8);

    titulo = {'Numero Palabras Relevantes'; 'para Clase Indicada'};
    title(titulo);
    legend('#TerImp ','Location','eastoutside','Orientation','vertical');
    set(gca,'FontSize',11);
    xlabel('Cantidad de Terminos Leidos');
    ylabel('Numero de Palabras');
    set(gcf,'Color','w');
    grid;
    gcf;
    box;

    %% Grafico el porcentaje de terminos mas importantes de la clase indicada de cada documento.
    subplot(2,2,3);
    plot((ventanas(1:j)),mediaSumaPorcentajesTerminos,'LineWidth',1,'MarkerSize',8);

    titulo = {'Porcentaje Palabras Relevantes'; 'para Clase Indicada'};
    title(titulo);
    legend('%TerImp ','Location','eastoutside','Orientation','vertical');
    set(gca,'FontSize',11);
    xlabel('Cantidad de Terminos Leidos');
    ylabel('Porcentaje de Terminos Importantes');
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
%{
nombreFiguraFig = [directorioFiguras '\Fig\' nombreDataset '_Analisis30Terminos_Clase_' char(nombreClases(claseActual))];
nombreFiguraSvg = [directorioFiguras '\Svg\' nombreDataset '_Analisis30Terminos_Clase_' char(nombreClases(claseActual))];
nombreFiguraEps = [directorioFiguras '\Eps\' nombreDataset '_Analisis30Terminos_Clase_' char(nombreClases(claseActual))];
nombreFiguraPng = [directorioFiguras '\Png\' nombreDataset '_Analisis30Terminos_Clase_' char(nombreClases(claseActual))];
%}
nombreFiguraFig = [directorioFiguras '\Fig\' nombreDataset '_Analisis30Terminos'];
nombreFiguraSvg = [directorioFiguras '\Svg\' nombreDataset '_Analisis30Terminos'];
nombreFiguraEps = [directorioFiguras '\Eps\' nombreDataset '_Analisis30Terminos'];
nombreFiguraPng = [directorioFiguras '\Png\' nombreDataset '_Analisis30Terminos'];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc'); % Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


cd(directorioActual);

disp('El programa finalizo exitosamente');

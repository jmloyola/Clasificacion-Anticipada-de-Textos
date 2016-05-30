clear all; close all; clc;

load configuracion.mat

directorioActual = pwd;

%% Lugar donde se encuentran los .mat
directorioVariablesWorkspace = 'C:\Users\Juan Martin\Documents\GitHub\Clasificacion-Anticipada-de-Textos\Codigo Piloto\Variables del Workspace\';

pathMatrices = [directorioVariablesWorkspace nombreDataset '\' nombreDataset '_Matrices.mat'];
load(pathMatrices);

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
valorFinal = 35;
ventanas = valorInicial:tamanioVentana:valorFinal;
%% ventanas(end+1) = cantidadMaximaTerminosTest; % La variable cantidadMaximaTerminosTest se encuentra en el .mat Matrices

documentoTerminado = zeros(1,length(ventanas));

%% Tipos de Documentos
% Tipo 1 ---> Documentos que hasta la ventana han sido clasificados
% correctamente siempre.
% Tipo 2 ---> Documentos que en algún momento se clasificaron bien.
% Tipo 3 ---> Documentos que nunca se clasificaron correctamente.

% tipoDocumentos tiene n filas y m columnas, donde n=cantidad de documentos
% y m=cantidad de ventanas (epocas)
tipoDocumentos = zeros(size(Xtest,1),length(ventanas));

cantTipoUno = zeros(length(ventanas), 1);
cantTipoDos = zeros(length(ventanas), 1);
cantTipoTres = zeros(length(ventanas), 1);

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
            documentoTerminado(j) = documentoTerminado(j) + 1;
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
    subplot(2,1,1);
    plot((ventanas(1:j)),[lasefesnbm; accNBMM]','LineWidth',1,'MarkerSize',8);
    
    % Coloco el titulo a la figura. Notar que se usa cell, de esta forma creo
    % titulos con mas de una linea.
    %% titulo = {'Clasificacion Anticipada'; char(strcat({'Clase: '}, nombreClases(claseActual))); nombreDataset};
    titulo = {'Clasificacion Anticipada'; nombreDataset};
    title(titulo);
    legend('Macro F1', 'Accuracy','Location','eastoutside','Orientation','vertical');
    set(gca,'FontSize',11);
    xlabel('Cantidad de Terminos Leidos');
    ylabel('Porcentaje');
    set(gcf,'Color','w');
    grid;
    gcf;
    box;
    
    
    for x=1:size(Xtest,1)
        claseDelDocumento = Ytest(x);
        
        if (j == 1)
            if (NB0.pred(x) == claseDelDocumento)
                tipoDocumentos(x,j) = 1;
                cantTipoUno(j) = cantTipoUno(j) + 1;
            else
                tipoDocumentos(x,j) = 3;
                cantTipoTres(j) = cantTipoTres(j) + 1;
            end
        else
            if (tipoDocumentos(x,j-1) == 1)
                if (NB0.pred(x) == claseDelDocumento)
                    tipoDocumentos(x,j) = 1;
                    cantTipoUno(j) = cantTipoUno(j) + 1;
                else
                    tipoDocumentos(x,j) = 2;
                    cantTipoDos(j) = cantTipoDos(j) + 1;
                end
            end
            
            if (tipoDocumentos(x,j-1) == 2)
                tipoDocumentos(x,j) = 2;
                cantTipoDos(j) = cantTipoDos(j) + 1;
            end
            
            if (tipoDocumentos(x,j-1) == 3)
                if (NB0.pred(x) == claseDelDocumento)
                    tipoDocumentos(x,j) = 2;
                    cantTipoDos(j) = cantTipoDos(j) + 1;
                else
                    tipoDocumentos(x,j) = 3;
                    cantTipoTres(j) = cantTipoTres(j) + 1;
                end
            end
        end  
    end
    
    
    %% Grafico el numero de terminos mas importantes de la clase indicada de cada documento.
    subplot(2,1,2);
    %plot((ventanas(1:j)),[cantTipoUno(1:j)'; cantTipoDos(1:j)'; cantTipoTres(1:j)'],'LineWidth',1,'MarkerSize',8);
    plot((ventanas(1:j)),cantTipoUno(1:j)','LineWidth',1,'MarkerSize',8);
    hold on;
    plot((ventanas(1:j)),cantTipoDos(1:j)','LineWidth',1,'MarkerSize',8);
    plot((ventanas(1:j)),cantTipoTres(1:j)','LineWidth',1,'MarkerSize',8);
    hold off;

    titulo = 'Cantidad de Documentos de Cada Tipo';
    title(titulo);
    legend('Tipo 1', 'Tipo 2', 'Tipo 3','Location','eastoutside','Orientation','vertical');
    set(gca,'FontSize',11);
    xlabel('Cantidad de Terminos Leidos');
    ylabel('Cantidad de Documentos');
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

%% Guardo las figuras en disco.
nombreFiguraFig = [directorioFiguras '\Fig\' nombreDataset '_documentType'];
nombreFiguraSvg = [directorioFiguras '\Svg\' nombreDataset '_documentType'];
nombreFiguraEps = [directorioFiguras '\Eps\' nombreDataset '_documentType'];
nombreFiguraPng = [directorioFiguras '\Png\' nombreDataset '_documentType'];
saveas(f, nombreFiguraFig, 'fig');
saveas(f, nombreFiguraSvg, 'svg');
saveas(f, nombreFiguraEps, 'epsc'); % Guarda la figura en formato eps color.
saveas(f, nombreFiguraPng, 'png');


cd(directorioActual);

directorioVariablesWorkspace = [directorioActual '\Variables del Workspace\' nombreDataset];
if (exist(directorioVariablesWorkspace, 'dir') ~= 7)
    mkdir(directorioVariablesWorkspace);
end

cd(directorioVariablesWorkspace);

nombreArchivoSalida = [nombreDataset '_TipoDocumentos.mat'];
save(nombreArchivoSalida, 'tipoDocumentos');

cd(directorioActual);

disp('El programa finalizo exitosamente');

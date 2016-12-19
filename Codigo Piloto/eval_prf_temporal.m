function [p,r,f] = eval_prf_temporal(X,Y,c,t)
    tp = 0;
    fp = 0;
    tn = 0;
    fn = 0;

    o_parameter = 7;
    penalizacion_temporal = (1./(1 + exp(t - o_parameter)));
    
    p = (tp / (tp + fp)) * penalizacion_temporal
    r = (tp / (tp + fn)) * penalizacion_temporal

    erx=sign(X)-sign(Y);
    ofc=find(sign(Y)==c);
    pfc=find(sign(X)==c);

    p=(length(find(erx(pfc)==0))./length(pfc)).*100
    r=(length(find(erx(ofc)==0))./length(ofc)).*100
    if (isnan(p))
        p=0;
    end
    if (isnan(r))
        r=0;
    end

    f=(2.*p.*r)./(r+p);
    if (isnan(f))
        f=0;
    end
end


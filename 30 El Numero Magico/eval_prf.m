function [p,r,f] = eval_prf(X,Y,c)

erx=sign(X)-sign(Y);
ofc=find(sign(Y)==c);

pfc=find(sign(X)==c);



p=(length(find(erx(pfc)==0))./length(pfc)).*100;
r=(length(find(erx(ofc)==0))./length(ofc)).*100;
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
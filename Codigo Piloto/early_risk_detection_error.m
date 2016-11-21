function [ error_cost ] = early_risk_detection_error( stop, X, Y, k )
%EARLY_RISK_DETECTION_ERROR Summary of this function goes here
%   Detailed explanation goes here
cost_FP = ;
cost_FN = ;
cost_TP = ;
cost_TN = 0;

o_parameter = 7;
lc_o_k = 1 - (1./(1 + exp(k - o_parameter)));


cantidad_documentos = length(Y);
error_cost = 0;

for i=1:cantidad_documentos,
    if (stop(i) == 1)
        if (X(i) == Y(i))
            % TruePositive
            error_cost = error_cost + (lc_o_k(i) *cost_TP); 
        else
            % FalsePositive
            error_cost = error_cost + cost_FP;
        end
    else
        if (X(i) == Y(i))
            % FalseNegative
            error_cost = error_cost + cost_FN;
        else
            % TrueNegative
            error_cost = error_cost + cost_TN;
        end
    end
end

error_cost = error_cost / cantidad_documentos;
end


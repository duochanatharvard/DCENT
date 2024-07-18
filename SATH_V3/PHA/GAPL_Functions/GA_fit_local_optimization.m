function [Loss, Loss_sta, zscore, ita] = ...
          GA_fit_local_optimization(x,tim,ita,numeric,model_type,round_all)

    [Loss, Loss_sta, ~, zscore] = ...
         GA_fit_mu_given_other_para_SNG(x,tim,ita,numeric,model_type);
    
    if round_all >= 1 && size(ita,2) == 1

        [Loss,Loss_sta,zscore,ita] = GA_local_optimization...
                       (x,tim,ita,numeric,Loss,Loss_sta,zscore,model_type);

    elseif round_all >= 1 && size(ita,2) == 2

        [Loss,Loss_sta,zscore,ita] = GA_local_optimization_decadal...
                       (x,tim,ita,numeric,Loss,Loss_sta,zscore,model_type);

    end
end
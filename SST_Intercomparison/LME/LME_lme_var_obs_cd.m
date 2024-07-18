function [var_rnd,var_ship,pow] = LME_lme_var_obs_cd(P)

    do_NpD = 1;    % Always use Nation - Deck groups

    if strcmp(P.varname,'SST')
        
        if strcmp(P.method,'Bucket')
            if do_NpD == 0
                var_rnd  = 1.66;   var_ship = 1.09;    pow = 0.57;
            elseif do_NpD == 1
                var_rnd  = 1.72;   var_ship = 0.77;    pow = 0.57;
            end
        elseif strcmp(P.method,'ERI')
            if do_NpD == 0
                var_rnd  = 2.00;   var_ship = 1.50;    pow = 0.54;
            elseif do_NpD == 1
                var_rnd  = 2.00;   var_ship = 1.22;    pow = 0.57;
            end
        elseif strcmp(P.method,'Ship')
            if do_NpD == 0
                var_rnd  = 1.83;   var_ship = 1.30;    pow = 0.56;
            elseif do_NpD == 1
                var_rnd  = 1.86;   var_ship = 1.00;    pow = 0.57;
            end
        end
        
    elseif strcmp(P.varname,'NMAT')
        if do_NpD == 0
            var_rnd  = 0.00;   var_ship = 2.53;    pow = 0.61;
        elseif do_NpD == 1
            var_rnd  = 0.00;   var_ship = 2.61;    pow = 0.69;
        end
    end

    var_rnd = var_rnd / 2;
    var_ship = var_ship / 2;
end

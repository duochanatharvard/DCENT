% *************************************************************************
% Air and Ocean temperature Intercalibration Toolbox
% *************************************************************************
% 
% Data: T (air monthly)     / T_o (sea monthly)  / T_o_m (predicted sea monthly)
%       T_a (air high reso) / dT_a_dt (high_reso)
% x   : Parameters of the intercalibration model
%       > in optimization x is empty
%       > in prediction x is a set of A,B,C parameters to be used
% Para: Parameters of the analysis : reso / do_season
% Mode: 'Optimize' / 'Predict'

function out = AOI_toolbox(Data,x,Para,mode)

    Data.T   = confirm_column_vector(Data.T);
    
    if strcmp(mode,'Optimize')      || strcmp(mode,'o')
        Para.mode = 'o';
        Data      = call_month2high_reso(Data,Para);
        out       = fit_parameters(Data,Para);
        
    elseif strcmp(mode,'Predict')   || strcmp(mode,'p')
        Para.mode = 'p';
        Data      = call_month2high_reso(Data,Para);
        out       = predict(Data,x,Para);

    elseif strcmp(mode,'Loss')   || strcmp(mode,'l')
        Para.mode = 'l';
        out         = get_loss(x,Data,Para);        
    end
end

% *************************************************************************
% Optimization
% *************************************************************************
function x_fit = fit_parameters(Data,Para)

    options_ols = optimoptions('fmincon','Algorithm','interior-point',...
                               'MaxFunctionEvaluations',10000,'Display','off');
    if Para.do_season == 0
        x0     = [.5   20    10]';
        LB     = [0 0.001 0.001]';
        x_fit  = fmincon(@(x) get_loss(x,Data,Para),x0,[],[],[],[],LB,[],[],options_ols);
        x_fit(2:3) = x_fit(2:3) / 2e8;
        
    elseif Para.do_season == 1
        
        x0     = [.5    20    10     .5    pi/3     .5    pi/3     .5    pi/3]';
        LB     = [0 0.001 0.001  0.0001 -100*pi 0.0001 -100*pi 0.0001 -100*pi]';
        UB     = [10000 10000 10000  0.9999  100*pi 0.9999  100*pi 0.9999  100*pi]';

        x_fit  = fmincon(@(x) get_loss(x,Data,Para),x0,[],[],[],[],LB,UB,[],options_ols);
    end
end

% *************************************************************************
% Calculate Loss
% *************************************************************************
function L = get_loss(x,Data,Para)

    Data     = predict(Data,x,Para);
    if Para.do_season == 1,  intv = 12;  else,  intv = 1;  end
    T_o_m    = CDC_demean(Data.T_o_m,1,intv);
    T_o      = CDC_demean(Data.T_o,1,intv);
    dif      = T_o_m - T_o;
    
    l_use_loss           = Data.l_use_loss;
    l_use_loss(1:36)     = 0;
    dif(l_use_loss == 0) = nan;
    dif                  = dif - nanmean(dif);
    L                    = nanmean(dif.^2) * 100;
    
end

% *************************************************************************
% Intgration
% *************************************************************************
% Data = predict(Data,x,Para)
% 
% Extended DB98 model that is actually intergrated:
% dT_o/dt = A dT_a/dt - B T_o + C T_a
% Where:
% A = k gamma_a / gamma_o
% B = (  lambda_o + x_o + k x_a) [/ gamma_o]
% C = (k lambda_a + x_o + k x_a) [/ gamma_o]
% 
% Note that [--] denotes that the expression is not implimented due to 
% accuracy concerns during optimization.  Rather, gamma_o is fixed to 
% 2e8 J/m^2/K.  Parameters A, B, and C are magnified proportionally.
% 
% Underlying physical model:
% gamma_a dT_a/dt = -lambda_a T_a + x_a (T_o - T_a) + F
% gamma_o dT_o/dt = -lambda_o T_o + x_o (T_a - T_o) + k F
%
% [Reference]
% Barsugli, J. J., & Battisti, D. S. (1998). The basic effects of
% atmosphere?ocean thermal coupling on midlatitude variability. Journal of
% the Atmospheric Sciences, 55(4), 477-493.

function Data = predict(Data,x,Para)

    % format of x :: [A B C Amp_A Phi_A Amp_B Phi_B Amp_C Phi_C]
    T_o = zeros(size(Data.T_a,1)+1,size(Data.T_a,2));
    
    if ~isfield(Para,'reso'), Para.reso = .5;  end
  
    if strcmp(Para.mode,'o')
        scl = 2e8;
    elseif strcmp(Para.mode,'p') || strcmp(Para.mode,'l')
        scl = 1;
    end
    
    for ct = 1:size(Data.T_a,1)
        if Para.do_season == 1
            phi = ct * Para.reso / 360 * 2 * pi;
            A   = x(1) * (1 + x(4) * sin(x(5) + phi));
            B   = x(2) * (1 + x(6) * sin(x(7) + phi)) / scl;
            C   = x(3) * (1 + x(8) * sin(x(9) + phi)) / scl;
        else
            A   = x(1);
            B   = x(2) / scl;
            C   = x(3) / scl;
        end
        dy          = A * Data.dT_a_dt(ct,:) - B * T_o(ct,:) + C * Data.T_a(ct,:);
        T_o(ct+1,:) = T_o(ct,:) + dy * 86400 * Para.reso;
    end

    N_yr   = size(T_o(2:end,:),1)/(360/Para.reso);
    N_runs = size(T_o,2);

    Data.T_o_m = squeeze(nanmean(reshape(T_o(2:end,:),(30/Para.reso),12*N_yr,N_runs),1));
    Data.T_o_m = confirm_column_vector(Data.T_o_m);
    Data.t_m   = (1+1/24):1/12:(N_yr+1);    

end

% *************************************************************************
% Convert monthly data into higher resolution determined by Para.reso [day]
% *************************************************************************
function Data = call_month2high_reso(Data,Para)
    [Data.T_a, Data.dT_a_dt] = month2high_reso(Data.T,Para);
end

function [F_recons, dF_recons_dt] = month2high_reso(F_mon,Para)

    if ~isfield(Para,'reso'), Para.reso = .5;  end

    F_mon  = confirm_column_vector(F_mon);
    N_yr   = numel(F_mon)/12;
    N_mon  = numel(F_mon);
    
    A = zeros(N_mon,N_mon);
    for ct = 1:N_mon
        if ct == 1
            A(ct,1:2) = [7 1]/8;
        elseif ct == N_mon
            A(ct,ct-1:ct) = [1 7]/8;
        else
            A(ct,ct-1:ct+1) = [1 6 1]/8;
        end
    end
    
    F = A\F_mon;

    scl              = round(30 / Para.reso);
    original_time    = (1+1/(12*2)):1/12:N_yr+1;
    target_time      = (1+1/(12*scl*2)):1/(12*scl):N_yr+1;
    F_recons         = interp1(original_time,F,target_time,'linear');
    l1               = find(~isnan(F_recons),1);
    l2               = find(~isnan(F_recons),1,'last');
    F_recons(1:l1)   = F_recons(l1);
    F_recons(l2:end) = F_recons(l2);
    F_recons         = confirm_column_vector(F_recons);
    
    % F_recons         = F_recons - nanmean(F_recons(1:(2*360/Para.reso)));
    F_recons         = F_recons - nanmean(F_recons(1:(50/Para.reso)));
    dF_recons_dt     = [(F_recons(2:end) - F_recons(1:end-1)) ./ (86400*Para.reso); 0];
end

% *************************************************************************
% Other functions
% *************************************************************************
function a = confirm_column_vector(a)
    if size(a,1) == 1, a = a';  end
end

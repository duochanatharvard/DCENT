% [output,output_sig,fitted] = CDC_trend(field_y,field_x,dim)
% 
% CDC_trend computes the point wise linear dependency
% field_x can be one vector or have the same dimension as field_y
%   dim in this function is not omittable !!!
%  
% Last update: 2018-08-09

function [output,output_sig,fitted] = CDC_trend(field_y,field_x,dim,sig_alpha)

    dim_list = ones(1,numel(size(field_y)));
    dim_list(dim) = size(field_y,dim);
    dim_list_r = size(field_y);
    dim_list_r(dim) = 1;

    if CDC_sizcmp(field_x,field_y) == 0,
        if min(size(field_x)) == 1 && numel(size(field_x)) == 2,
            field_x = repmat(reshape(field_x,dim_list),dim_list_r);
        else
            error('Incorrect dimensionality!')
        end
    end
    
    if ~exist('sig_alpha','var'),  sig_alpha = 0.975; end

    % *****************************************************************
    % Remove NaN
    % *****************************************************************
    l_nan = isnan(field_x) | isnan(field_y);
    field_x (l_nan) = nan;
    field_y (l_nan) = nan;
    
    % *****************************************************************
    % Demaen
    % *****************************************************************
    field_anm_x = CDC_demean(field_x , dim);
    field_anm_y = CDC_demean(field_y , dim);
    
    l_effect = CDC_nansum( ~l_nan , dim) - 1;

    % *****************************************************************
    % Compute variance and covariance
    % *****************************************************************    
    cov_xy = CDC_nansum(field_anm_x .* field_anm_y,dim) ./ l_effect;
    var_xx = CDC_nansum(field_anm_x .* field_anm_x,dim) ./ l_effect;
    
    % *****************************************************************
    % Compute slope and intercept
    % *****************************************************************
    slope = cov_xy ./ var_xx;
    intercept = nanmean(field_y,dim) - nanmean(field_x,dim) .* slope;

    if nargout > 1,
        % *****************************************************************
        % Compute MSE
        % *****************************************************************
        fitted = repmat(slope,dim_list) .* field_x + repmat(intercept,dim_list);
        err  = CDC_nansum((fitted - field_y).^2,dim) ./ (l_effect - 1);

        x_sqrt_2 = CDC_nansum(field_anm_x.^2,dim);
        mu_sqrt_2 = nanmean(field_x,dim).^2;

        output_std = sqrt(err ./ x_sqrt_2);
        intercept_std    = sqrt(err .* (1 ./ (l_effect + 1) + mu_sqrt_2 ./ x_sqrt_2));

        n_std = tinv(sig_alpha,l_effect-1);

        % *****************************************************************
        % Compute significance level
        % *****************************************************************    
        slope_upper       =    output_std .* n_std + slope;
        slope_lower       =  - output_std .* n_std + slope;
        intercept_upper   =    intercept_std .* n_std + intercept;
        intercept_lower   =  - intercept_std .* n_std + intercept;
    end
    
    % *****************************************************************
    % Prepare output
    % *****************************************************************
    output{1} = slope;
    output{2} = intercept;
    
    if nargout > 1,
        output_sig{1}.upper = slope_upper;
        output_sig{1}.lower = slope_lower;
        
        output_sig{2}.upper = intercept_upper;
        output_sig{2}.lower = intercept_lower;
    end

end
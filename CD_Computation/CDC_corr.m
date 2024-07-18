% [output,l_effect, R2, R2_quantile, pic_mem] = CDC_corr(field_1,field_2,dim)
% 
% CDC_corr computes the correlation in certain dimension
% 
% Last update: 2018-08-09

function [output,l_effect, R2, R2_quantile, pic_mem] = CDC_corr(field_1,field_2,dim)

    if  nargin == 2 && size(field_1,1) ~= 1,
        dim = 1;
    elseif nargin == 2 && size(field_1,1) == 1,
        dim = 2;    
    end

    l_nan = isnan(field_1) | isnan(field_2);
    field_1 (l_nan) = nan;
    field_2 (l_nan) = nan;
    
    field_anm_1 = CDC_demean(field_1 , dim);
    field_anm_2 = CDC_demean(field_2 , dim);
    
    l_effect = CDC_nansum( ~l_nan , dim) - 1;
    
    var_1  = CDC_nansum(field_anm_1 .* field_anm_1,dim) ./ l_effect;
    var_2  = CDC_nansum(field_anm_2 .* field_anm_2,dim) ./ l_effect;
    cov_12 = CDC_nansum(field_anm_1 .* field_anm_2,dim) ./ l_effect;
    
    output = cov_12 ./ sqrt(var_1) ./ sqrt(var_2);
    
    l = l_effect < 3;
    output(l)   = nan;
    l_effect(l) = nan;

    % statistical test
    % reference: http://onlinestatbook.com/2/sampling_distributions/samp_dist_r.html
    if nargout > 2
        rng(0);
        N = 100;
        output(output>1) = 0.99999999;
        z       = 0.5*log((1+output)./(1-output));
        z_std   = 1./sqrt(l_effect - 2);
        out_member = nan([size(output) N]);
        dim_2 = numel(size(out_member));
        for ct = 1:100
            temp       = normrnd(z,z_std);
            out_member = CDC_assign(out_member,temp,dim_2,ct);
        end
        pic_mem = (exp(2*out_member) - 1)./ (exp(2*out_member) + 1);
        R2_quantile = squeeze(quantile(pic_mem.^2,[0.025 0.25 0.75 0.975],dim_2));
        R2     = output.^2;
    end

end
% output = CDC_var(field_1,dim,field_2)
% 
% CDC_var computes the variance or the covariance in certain dimension
% 
% Last update: 2018-08-09

function [output,l_effect] = CDC_var(field_1,dim,field_2)

    if  nargin == 1 && size(field_1,1) ~= 1,
        dim = 1;
    elseif nargin == 1 && size(field_1,1) == 1,
        dim = 2;    
    end

    if nargin < 3,
        field_2 = field_1;
    end

    l_nan = isnan(field_1) | isnan(field_2);
    field_1 (l_nan) = nan;
    field_2 (l_nan) = nan;
    
    field_anm_1 = CDC_demean(field_1 , dim);
    field_anm_2 = CDC_demean(field_2 , dim);
    
    l_effect = CDC_nansum( ~l_nan , dim) - 1;
    
    output = CDC_nansum(field_anm_1 .* field_anm_2,dim) ./ l_effect;

end
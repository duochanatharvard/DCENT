% [output,l_effect] = CDC_std(field,dim)
% 
% CDC_var computes the standard deviation and normalize the matrix
% 
% Last update: 2018-08-09

function [output,field_std,l_effect] = CDC_std(field,dim)

    if  nargin == 1 && size(field,1) ~= 1,
        dim = 1;
    elseif nargin == 1 && size(field,1) == 1,
        dim = 2;    
    end
    
    [field_var,l_effect] = CDC_var(field,dim);
    output = sqrt(field_var);
    
    if nargout > 1,
        
        dim_list = ones(1,numel(size(field)));
        dim_list(dim) = size(field,dim);

        field_std = field ./ repmat(output,dim_list);
    end

end
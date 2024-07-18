% output = CDC_demean(field,dim,m)
%  
% CDC_var removes the mean from a matrix in certain dimension
% 
% It allows to compute the mean by every m points, such that to remove
% periodic signals like seasonal and diurnal cycles
% 
% Last update: 2018-08-09

function output = CDC_demean(field,dim,interval)

    if  nargin == 1 && size(field,1) ~= 1,
        dim = 1;
    elseif nargin == 1 && size(field,1) == 1,
        dim = 2;    
    end

    if nargin < 3,
        interval = 1;
    end
    
    if interval == 1,
        
        field_mean = nanmean(field,dim);

        dim_list = ones(1,numel(size(field)));
        dim_list(dim) = size(field,dim);

        output = field - repmat(field_mean,dim_list);
        
    else

        output = nan(size(field));
        for ct = 1:interval
            
            list = [1 : interval : size(field,dim)] + ct - 1;
            
            field_sub = CDC_subset(field,dim,list);
            
            field_sub_demean = CDC_demean(field_sub,dim,1);
            
            output = CDC_assign(output,field_sub_demean,dim,list);                  
        end
    end
end
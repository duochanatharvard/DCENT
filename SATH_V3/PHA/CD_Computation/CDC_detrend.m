% output = CDC_detrend(field_y,dim,interval,field_x)
% 
% CDC_detrend computes the point wise linear dependency
% field_x can be one vector or have the same dimension as field_y
% when omitted, field_x is 1:1:N, where N is the size of field_y in dim
%
%  
% Last update: 2018-08-09

function output = CDC_detrend(field_y,dim,interval,field_x)

    if  nargin == 1 && size(field_y,1) ~= 1,
        dim = 1;
    elseif nargin == 1 && size(field_y,1) == 1,
        dim = 2;    
    end

    if nargin < 3,
        interval = 1;
    end

    if nargin < 4,
        field_x = 1:size(field_y,dim);
    end

    if interval == 1,
        
        [~,~,fitted] = CDC_trend(field_y,field_x,dim);
        output = field_y - fitted;
        
    else
        
        output = nan(size(field_y));
        for ct = 1:interval
            
            list = [1 : interval : size(field_y,dim)] + ct - 1;
            
            field_sub = CDC_subset(field_y,dim,list);
            
            field_sub_detrend = CDC_detrend(field_sub,dim,1);
            
            output = CDC_assign(output,field_sub_detrend,dim,list);
        end
    end
end
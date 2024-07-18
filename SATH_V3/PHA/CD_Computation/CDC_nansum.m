% output = CDC_nansum(x,dim)
%  
% CDC_nansum compute the summation by ignoring nan, when all elements on
% certain dimension are nan, CDF_nansum returns nan rather than 0 as the
% nansum function in matlab.
% 
% Last update: 2018-08-09

function output = CDC_nansum(input,dim)

    if  nargin == 1 && size(input,1) ~= 1,
        dim = 1;
    elseif nargin == 1 && size(input,1) == 1,
        dim = 2;    
    end
    
    input_raw = input;
    input(isnan(input)) = 0;

    output = sum(input,dim);
    logic  = all(isnan(input_raw),dim);
    output(logic) = NaN;
end
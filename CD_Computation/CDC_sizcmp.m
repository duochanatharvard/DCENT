% output = CDC_sizcmp(A,B)
% 
% CDC_sizcmp tells if matrix A and B have the same dimensionality
%  
% Last update: 2018-08-14

function output = CDC_sizcmp(A,B)
    
    siz_a = size(A);
    siz_b = size(B);
    
    if numel(siz_a) ~= numel(siz_b),
        output = false;
    else
        output = all(siz_a == siz_b);
    end
end

    